# Reproduce Side Channel Results

In the main paper we demonstrated three side channels, a SQLite channel, a PMDK key-value store channel, and a wolfSSL channel. To reproduce these results, first set up the NVRAM Server following [this instruction](../setup/NVRAMServer.md). And then each covert channel requires additional set up steps.

|    Metric    | Estimation |
| :----------: | :--------: |
| Compute Time |  2 hours   |
|  Disk Space  |   12 GiB   |

## Reproduce SQLite Side Channel (Figure 12-13)

### Install Dependencies

```shell
$ sudo apt install sqlite3
$ sqlite3 --version
3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837balt1
```

### Configure Optane DIMMs SQLite Side Channel

```shell
# Find the Optane PMEM device, e.g., here the 124GB device.
# If you see more than one PMEM devices, then remove all of them and only leave
#   the pmem0 which is created on DRAM
$ ndctl list -u
[
  {
    "dev":"namespace1.0",
    "mode":"fsdax",
    "map":"dev",
    "size":"124.03 GiB (133.18 GB)",
    "uuid":"94fafe15-0cb7-47f3-9663-6ddc2f662fee",
    "sector_size":512,
    "align":2097152,
    "blockdev":"pmem1"
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":"32.00 GiB (34.36 GB)",
    "sector_size":512,
    "blockdev":"pmem0"
  }
]

# Delete the Optane PMEM device
$ sudo ndctl destroy-namespace -f namespace1.0
destroyed 1 namespace

# In case of "Device or resource busy" error, unmount pmem devices.
$ mount -v | grep pmem
/dev/pmem0 on /mnt/dram type ext4 (rw,relatime,dax)
/dev/pmem1 on /mnt/pmem type ext4 (rw,relatime,dax)
$ umount /mnt/pmem /mnt/dram
$ sudo ndctl destroy-namespace -f namespace1.0
destroyed 1 namespace


# Re-create the PMEM devices for side channel experiments
$ sudo bash NVLeak/nvleak/scripts/machine/optane.sh ndctl fsdevdax

# Check created PMEM devices, make sure the "mode" is "devdax",
#   and "name" is "dax-victim" and "dax-attacker"
$ ndctl list -u
[
  {
    "dev":"namespace1.0",
    "mode":"fsdax",
    "map":"dev",
    "size":"7.00 GiB (7.52 GB)",
    "uuid":"6675fb6a-fd8c-4724-85f8-b44dc2bca74c",
    "sector_size":512,
    "align":1073741824,
    "blockdev":"pmem1",
    "name":"dax-victim"
  },
  {
    "dev":"namespace1.2",
    "mode":"devdax",
    "map":"dev",
    "size":"7.00 GiB (7.52 GB)",
    "uuid":"882cdf50-4210-4414-a1c9-f48524d198ca",
    "chardev":"dax1.2",
    "align":1073741824,
    "name":"dax-attacker"
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":"32.00 GiB (34.36 GB)",
    "sector_size":512,
    "blockdev":"pmem0"
  }
]

# Mount PMEM devices
$ sudo -i su
$ cd /home/usenix/NVLeak/nvleak/user/side_channel/setup
$ bash mount.sh

# Check if mount.sh works fine
$ echo $?
0
$ mount -v | grep pmem
/dev/pmem0 on /mnt/dram type ext4 (rw,relatime,dax)
/dev/pmem1 on /mnt/pmem type ext4 (rw,relatime,dax)
```

### Build and Prepare the SQLite Side Channel

```shell
# Build the side_channel attacker code
$ cd NVLeak/nvleak/user/side_channel/nvleak
$ make
# Check if the built binary works
$ ./side_channel
Missing argument pmem_file_path
Usage: side_channel 
       -f pmem_file_path 
       -l lib_file_path
       -i iterations
       -s scratch_op
       -o side_channel|scratch
       -c cache_set_beg
       -p probe_set_index (0 to 255)

# Download the NPPES data
$ cd NVLeak/nvleak/user/side_channel/data
$ bash prepare.sh

# Create SQLite database from NPPES data
$ cd NVLeak/nvleak/user/side_channel/sqlite
$ python3 nppes_db.py gen-sqlite-basic
$ python3 nppes_db.py gen-sqlite-ranged
```

### Run SQLite Side Channel (Figure 12 and 13)

This experiment takes ~40 mins to run.

```shell
$ sudo -i su
$ cd /home/usenix/NVLeak/nvleak/user/side_channel/sqlite
$ ./run.sh
```

Troubleshoot:

1. If the output is empty with only this error message:

   ```
   Opening file /dev/dax1.1
   Could not open file: /dev/dax1.1
   ```

   Then `ls /dev/dax*` to find which dax device is available, and then update the `nvleak/user/side_channel/common.sh` to change `dax_dev` variable to the available dax device.

### Collect SQLite Results and Generate Plots

On your Dev Server, fetch the results and generate plots. Note the result takes ~12 GiB of disk space.

**Figure 12**

```shell
$ cd NVLeak/data
$ bash copy.sh # Or manually copy the results from NVRAM Server to Dev Server

$ cd NVLeak/report/data/reproduce/fig12/
$ vim fetch.sh # Fill the task id according to the table below, and check an example in data/reference/fig12/fetch.sh
$ bash fetch.sh

$ cd NVLeak/report/
$ sed -i 's/\#reproduce\/fig12/reproduce\/fig12/g' figure/plots.csv
$ vim content/figure/12.tex # uncomment the 'reproduce' sub figures
$ make # generate the report 'paper.pdf'
```

The table below shows a list of SQLite operations (defined by `NVLeak/nvleak/user/side_channel/sqlite/run.sh`) and their corresponding data name (used by `NVLeak/report/data/reproduce/fig12/fetch.sh`). **Note: the `insert1000` is `I2` and `insert10000` is `I1`. This order is different from `update100` and `udpate1000`.**

| SQLite runner script operation | Data Name in the Report |
| :----------------------------- | :---------------------- |
| count                          | C1                      |
| sort                           | S1                      |
| query                          | Q1                      |
| insert1000                     | I2                      |
| insert10000                    | I1                      |
| update100                      | U1                      |
| update1000                     | U2                      |

**Figure 13**

```shell
$ cd NVLeak/report/data/reproduce/fig13/
$ vim fetch.sh # Fill the task id where monthx is linked as Mx, e.g., month1 result is linked as M1.csv
$ bash fetch.sh

$ cd NVLeak/report/
$ sed -i 's/\#reproduce\/fig13/reproduce\/fig13/g' figure/plots.csv
$ vim content/figure/13.tex # uncomment the 'reproduce' sub figures
$ make # generate the report 'paper.pdf'
```

## Reproduce PMDK Side Channel (Figure 14)

### Build Dependencies

```shell
$ cd NVLeak/nvleak/user/side_channel/libpmemobj-cpp
$ mkdir build && cd build
$ cmake ..                         \
    -DTESTS_USE_VALGRIND=0         \
    -DTEST_CONCURRENT_HASHMAP=1    \
    -DTEST_SELF_RELATIVE_POINTER=1 \
    -DTEST_RADIX_TREE=1            \
  ;
$ make -j $(nproc)
```

### Configure Optane DIMMs for PMDK Side Channel

```shell
# Find the Optane PMEM device, e.g., here the 124GB device.
# If you see more than one PMEM devices, then remove all of them and only leave
#   the pmem0 which is created on DRAM
$ ndctl list -u
[
  {
    "dev":"namespace1.0",
    "mode":"fsdax",
    "map":"dev",
    "size":"7.00 GiB (7.52 GB)",
    "uuid":"6675fb6a-fd8c-4724-85f8-b44dc2bca74c",
    "sector_size":512,
    "align":1073741824,
    "blockdev":"pmem1",
    "name":"dax-victim"
  },
  {
    "dev":"namespace1.2",
    "mode":"devdax",
    "map":"dev",
    "size":"7.00 GiB (7.52 GB)",
    "uuid":"882cdf50-4210-4414-a1c9-f48524d198ca",
    "chardev":"dax1.2",
    "align":1073741824,
    "name":"dax-attacker"
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":"32.00 GiB (34.36 GB)",
    "sector_size":512,
    "blockdev":"pmem0"
  }
]

# Delete the Optane PMEM device
$ sudo umount /mnt/pmem /mnt/dram
$ sudo ndctl destroy-namespace -f namespace1.0
destroyed 1 namespace
$ sudo ndctl destroy-namespace -f namespace1.2
destroyed 1 namespace

# Check and make sure there is only 'pmem0' left
$ ndctl list -u
{
  "dev":"namespace0.0",
  "mode":"fsdax",
  "map":"mem",
  "size":"32.00 GiB (34.36 GB)",
  "sector_size":512,
  "blockdev":"pmem0"
}

# Set up environments
$ cd NVLeak/nvleak/user/side_channel/map_cli
$ sudo bash setup.sh
# When prompt for choices, choose "1" or "y" to proceed

# Check if there is a 'dax-victim' and a 'dax-attacker' device
$ ndctl list -u
[
  {
    "dev":"namespace1.0",
    "mode":"fsdax",
    "map":"dev",
    "size":"15.00 GiB (16.11 GB)",
    "uuid":"b3ca7959-5042-4743-a1c2-71ca4d01e31b",
    "sector_size":512,
    "align":1073741824,
    "blockdev":"pmem1",
    "name":"dax-victim"
  },
  {
    "dev":"namespace1.3",
    "mode":"devdax",
    "map":"dev",
    "size":"15.00 GiB (16.11 GB)",
    "uuid":"6a5b0184-f9dd-4658-9ad0-9203095dd94a",
    "chardev":"dax1.3",
    "align":1073741824,
    "name":"dax-attacker"
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":"32.00 GiB (34.36 GB)",
    "sector_size":512,
    "blockdev":"pmem0"
  }
]
```

### Run PMDK Side Channel

```shell
$ sudo -i su
$ cd /home/usenix/NVLeak/nvleak/user/side_channel/map_cli

# Init the key-value store
$ ./run.sh # Then enter '1' to select './runners/0_init.sh' script to run
# It takes ~1 min to run

# Check if the store data file is created
$ ls -lh /mnt/pmem/map_data 
-rw------- 1 root root 8.0M Oct 13 00:11 /mnt/pmem/map_data

# Run the experiment
$ ./run.sh # Then enter '10' to select './runners/9_read_only_no_init.sh'
```

Troubleshoot

1. If `run.sh` gives following error

   ```plain
   Traceback (most recent call last):
     File "../../../nvleak/parse.py", line 61, in <module>
       parse()
     File "../../../nvleak/parse.py", line 29, in parse
       writer = csv.DictWriter(f, fieldnames=res[0].keys())
   IndexError: list index out of range
   ```

   Then check the `results/<task_id>/side_channel.log`, if it says `Could not open file: dax_dev_not_found`, then check `NVLeak/nvleak/user/side_channel/common.sh`, find the corresponding variable setting code, and execute it to see if it gives a valid `dax*.*` output:
      1. Output a `dax*.*`, then log out current shell and re-login so the variable can be init with the correct value
      2. Output a `dax_dev_not_found`, then go to the Optane DIMM set up section to redo steps. Then make sure there's a dax with "name" as "dax-attacker" when executing `ndctl list`
2. If `run.sh` stucks after printing many lines:
   
   Try press Enter to see if it exits, or wait another min before killing the process.

### Collect PMDK Results and Generate Plots

On your Dev Server, fetch the results and generate plots.

```shell
$ cd NVLeak/data
$ bash copy.sh # Or manually copy the results from NVRAM Server to Dev Server

# Assuming the task id is '20221013-00-13-58'
$ fig14_result="20221013-00-13-58"

$ cd NVLeak/report/data/reproduce/fig14/
$ bash fetch.sh "${fig14_result}"

$ cd NVLeak/report/
$ sed -i 's/\#reproduce\/fig14/reproduce\/fig14/g' figure/plots.csv
$ vim content/figure/14.tex # uncomment the 'reproduce' sub figures
$ make # generate the report 'paper.pdf'
```

If the output graph does not show the patterns, then check the generated plot `NVLkea/report/figure/plot/reproduce/fig14-pmdk-kv-memory-pattern-all.png` to find four patterns, and update their x-axis value in the plotting script `NVLkea/report/figure/src/fig14-pmdk-kv-memory-pattern.R`.

