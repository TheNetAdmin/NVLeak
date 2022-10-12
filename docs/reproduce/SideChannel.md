# Reproduce Side Channel Results

In the main paper we demonstrated three side channels, a SQLite channel, a PMDK key-value store channel, and a wolfSSL channel. To reproduce these results, first set up the NVRAM Server following [this instruction](../setup/NVRAMServer.md). And then each covert channel requires additional set up steps.

## Reproduce SQLite Side Channel (Figure 12-13)

### Install Dependencies

```shell
$ sudo apt install sqlite3
$ sqlite3 --version
3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837balt1
```

### Configure Optane DIMMs

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

```shell
$ sudo -i su
$ cd /home/usenix/NVLeak/nvleak/user/side_channel/sqlite
$ ./run.sh
```
