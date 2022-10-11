# Reproduce Covert Channel Results

In the main paper we demonstrated two covert channels, a cross-VM channel and a file system inode-based channel. To reproduce these results, first set up the NVRAM Server following [this instruction](../setup/NVRAMServer.md). And then each covert channel requires additional set up steps.

## Reproduce Cross-VM Covert Channel

### Build QEMU from Source Code

The QEMU package provided by Ubuntu is quite old (QEMU 1.4.2). To use more up-to-date QEMU (6.2.0), we'd suggest to build QEMU from source:

```shell
$ sudo apt-get build-dep qemu

$ cd /home/usenix
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

### Configure the Optane DIMMs

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
$ bash /home/usenix/NVLeak/nvleak/scripts/machine/smt.sh
# You may need this line to configure git for the repo
$ git config --global --add safe.directory /home/usenix/NVLeak/nvleak/user/covert_channel/cross_vm
# Run a sample covert channel, if it stucks for more than a few seconds, see
#   the following troubleshooting steps for solutions
$ cd /home/usenix/NVLeak/nvleak/user/covert_channel/cross_vm
$ ./scripts/nvleak/covert.sh debug_single

# If the above single test works fine, run the following line to run the full experiment
$ ./scripts/nvleak/covert.sh all
```

Troubleshooting:

1. Failed to set CPU scaling governor to performance mode:
   1. Reboot the machine into BIOS, disable HyperThreading and retry.
   2. This is because when disabling SMT using the script, the CPUs can get unexpected IDs under `/sys/`, which affects the runner script to set their scaling governor.
2. The `covert.sh` stucks:
   1. Check the output under `results/debug_single/<job_id>/<sub_job_id>/*.log` for more info
   2. Typically you'd need to update the QEMU path defined in `scripts/nvleak/qemu_nvram.sh`
