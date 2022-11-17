# Reproduce Covert Channel Results

In the main paper we demonstrated two covert channels, a cross-VM channel and a file system inode-based channel. To reproduce these results, first set up the NVRAM Server following [this instruction](../setup/NVRAMServer.md). And then each covert channel requires additional set up steps.

## Reproduce Cross-VM Covert Channel (Figure 9)

### Build QEMU from Source Code

The QEMU package provided by Ubuntu is quite old (QEMU 1.4.2). To use more up-to-date QEMU (6.2.0), we'd suggest to build QEMU from source:

```shell
$ sudo apt-get build-dep qemu

$ cd $PROJ_ROOT
$ wget https://download.qemu.org/qemu-6.0.0.tar.xz
$ tar xvJf qemu-6.0.0.tar.xz
$ cd qemu-6.0.0
$ mkdir build && cd build
$ ../configure
$ make -j $(nproc)
$ ./qemu-system-x86_64 --version
QEMU emulator version 6.0.0
Copyright (c) 2003-2021 Fabrice Bellard and the QEMU Project developers
```

### Configure Optane DIMMs for VMs

```shell
# Find the Optane PMEM device, e.g., here the 124GB device
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

# Re-create the PMEM devices for covert channel experiments
$ sudo bash NVLeak/nvleak/scripts/machine/optane.sh ndctl devdax

# Check created PMEM devices, make sure the "mode" is "devdax",
#   and "name" is "dax-sender" and "dax-receiver"
$ ndctl list -u
[
  {
    "dev":"namespace1.0",
    "mode":"devdax",
    "map":"dev",
    "size":"7.00 GiB (7.52 GB)",
    "uuid":"4abab6e2-1483-4337-b49f-35c22029c23f",
    "chardev":"dax1.0",
    "align":1073741824,
    "name":"dax-sender"
  },
  {
    "dev":"namespace1.1",
    "mode":"devdax",
    "map":"dev",
    "size":"7.00 GiB (7.52 GB)",
    "uuid":"96373c16-b70c-4a7b-825b-fe010b731029",
    "chardev":"dax1.1",
    "align":1073741824,
    "name":"dax-receiver"
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

### Build and Run the Cross-VM Covert Channel

```shell
$ cd NVLeak/nvleak/user/covert_channel/cross_vm
$ ./configure
$ make -j $(nproc)

# Test if the Cross-VM channel works
$ sudo -i su
# Disable SMT if haven't done so
$ bash $PROJ_ROOT/NVLeak/nvleak/scripts/machine/smt.sh
# You may need this line to configure git for the repo
$ git config --global --add safe.directory $PROJ_ROOT/NVLeak/nvleak/user/covert_channel/cross_vm

# Run a sample covert channel, if it stucks for more than a few seconds, see
#   the following troubleshooting steps for solutions
$ cd $PROJ_ROOT/NVLeak/nvleak/user/covert_channel/cross_vm
$ ./scripts/nvleak/covert.sh debug_single

# If the above single test works fine, run the following line to run the full experiment
$ vim ./scripts/nvleak/covert.sh # (Strongly recommended) edit the SlackURL and remove the `export no_slack=y` to set up Slack notification
$ ./scripts/nvleak/covert.sh all
```

The full set of experiment takes ~8 hours to run, so we strongly suggest you to enable the Slack notification to track the experiment progress.

Troubleshooting:

1. Failed to set CPU scaling governor to performance mode:
   1. Reboot the machine into BIOS, disable HyperThreading and retry.
   2. This is because when disabling SMT using the script, the CPUs can get unexpected IDs under `/sys/`, which affects the runner script to set their scaling governor.
2. The `covert.sh` stuck:
   1. Check the output under `results/debug_single/<job_id>/<sub_job_id>/*.log` for more info
   2. Typically you'd need to update the QEMU path defined in `scripts/nvleak/qemu_nvram.sh`

### Collect Cross-VM Covert Channel Results and Generate Plots

On your Dev Server, parse results (it can take 4 hours or even longer, depending on the performance of your Dev Server):

```shell
$ cd NVLeak/data
$ bash copy.sh # Or manually copy the results from NVRAM Server to Dev Server

# Parse the results and store them locally, not yet upload to the MongoDB
# Assuming the job folder is "covert_cross_vm/results/all/20221011032039"
$ fig9_result="20221011032039"
$ batch_root=covert_cross_vm/results/all \
    ./parse.sh \
    "${fig9_result}" \
    -m \
  ;

# Now upload results to the MongoDB
# If pymongo gives 'AuthenticationFailed' error, please follow the
#   ../setup/DevServer.md to set up the MongoDB connection for parser scripts
#   and then try again
$ batch_root=covert_cross_vm/results/all \
    ./parse.sh \
    "${fig9_result}" \
    -m \
    -u \
  ;
```

Generate plots:

```shell
$ cd NVLeak/report/data/reproduce/fig9/
# If pymongo gives 'AuthenticationFailed' error, please set up the MongoDB
#   username and password for parser scripts, following ../setup/DevServer.md
# Choose a single to visualize and set its dir name (i.e., it's job id) as fig9_signal
#   browse the NVLeak/data/covert_cross_vm/results/all/${fig9_results} to choose one sub folder
#   also check the 'results/config.json' under sub folders to identify the signal you need
#   here we choose the 1606th job in the folder, using the following command:
#     $ ls -1 | sed -n '1606p'
$ fig9_signal=20221011060201-a380aef-nv-4
$ bash ./fetch.sh "${fig9_result}" "${fig9_signal}"

$ cd NVLeak/report/
$ sed -i 's/\#reproduce\/fig9b-covert-vm-summary/reproduce\/fig9b-covert-vm-summary /g' figure/plots.csv
$ sed -i 's/\#reproduce\/fig9c-covert-vm-signal-receiver/reproduce\/fig9c-covert-vm-signal-receiver /g' figure/plots.csv
$ vim content/figure/9.tex # uncomment the 'reproduce' sub figures
$ make # generate the report 'paper.pdf'
```

## Reproduce File System Inode Covert Channel (Figure 10)

### Configure Optane DIMMs for FS Inode Channel

This covert channel needs a different Optane DIMMs configuration compared to the cross-VM channel:

```shell
# Find and remove the current Optane DIMM namespaces 1.0 and 1.1
$ ndctl list
[
  {
    "dev":"namespace1.0",
    "mode":"devdax",
    "map":"dev",
    "size":7516192768,
    "uuid":"4abab6e2-1483-4337-b49f-35c22029c23f",
    "chardev":"dax1.0",
    "align":1073741824,
    "name":"dax-sender"
  },
  {
    "dev":"namespace1.1",
    "mode":"devdax",
    "map":"dev",
    "size":7516192768,
    "uuid":"96373c16-b70c-4a7b-825b-fe010b731029",
    "chardev":"dax1.1",
    "align":1073741824,
    "name":"dax-receiver"
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":34359738368,
    "sector_size":512,
    "blockdev":"pmem0"
  }
]
$ sudo ndctl destroy-namespace -f namespace1.0
$ sudo ndctl destroy-namespace -f namespace1.1

# Set up Optane DIMMs
$ cd NVLeak/nvleak
$ sudo bash scripts/machine/optane.sh ndctl

# Check and make sure there's only one pmem namespace, in 'fsdax' mode
$ ndctl list -u
[
  {
    "dev":"namespace1.0",
    "mode":"fsdax",
    "map":"dev",
    "size":"124.03 GiB (133.18 GB)",
    "uuid":"2472e860-7b9e-4f2f-a356-8c3697c87534",
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
```

### Build required packages

This experiment requires e2fsprogs v1.46.4 or newer version. If this version is not provided by your Linux distro, then build it from source:

```shell
$ cd $HOME
$ wget https://github.com/tytso/e2fsprogs/archive/refs/tags/v1.46.4.zip
$ mv v1.46.4.zip e2fsprogs-1.46.4.zip
$ unzip e2fsprogs-1.46.4.zip
$ cd e2fsprogs-1.46.4
$ mkdir -p build && cd build
$ ../configure
$ make -j $(nproc)

# Check if the compiled tool works
$ ./misc/mke2fs 
Usage: mke2fs [-c|-l filename] [-b block-size] [-C cluster-size]
        [-i bytes-per-inode] [-I inode-size] [-J journal-options]
        [-G flex-group-size] [-N number-of-inodes] [-d root-directory]
        [-m reserved-blocks-percentage] [-o creator-os]
        [-g blocks-per-group] [-L volume-label] [-M last-mounted-directory]
        [-O feature[,...]] [-r fs-revision] [-E extended-option[,...]]
        [-t fs-type] [-T usage-type ] [-U UUID] [-e errors_behavior][-z undo_file]
        [-jnqvDFSV] device [blocks-count]
```

### Set Up and Run the Inode Covert Channel

```shell
# Set up the filesystem
$ sudo -i su
$ cd $PROJ_ROOT/NVLeak/nvleak/user/covert_channel/inode
$ bash mount.sh

# Check if mount.sh works fine
$ echo $?
0
$ mount -v | grep pmem
/dev/pmem0 on /mnt/dram type ext4 (rw,relatime,dax)
/dev/pmem1 on /mnt/pmem type ext4 (rw,relatime,dax)

# Build the inode covert poc binary
$ make

# Run the covert channel on NVRAM and DRAM separately
$ test_dev=pmem ./run.sh single
$ test_dev=dram ./run.sh single

# Parse results
$ pmem_task_id=20221011-14-44-53
$ dram_task_id=20221011-14-46-18
$ python3 parse.py results/single/${pmem_task_id}
$ python3 parse.py results/single/${dram_task_id}
```

### Fetch Results and Generate Plots

On your Dev Server:

```shell
$ cd NVLeak/data
$ bash copy.sh

# Copy data to report
$ cd NVLeak/report/data/reproduce/fig10
$ bash fetch.sh ${pmem_task_id} ${dram_task_id}
```
