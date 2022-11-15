# Set up the NVRAM Server

## Software and hardware environment

As specified in the paper, we set up the NVRAM server with the following software and hardware:

| Hardware/Software | Version                                                                                             |
| :---------------- | :-------------------------------------------------------------------------------------------------- |
| CPU               | Intel(R) Xeon(R) Gold 6230 CPU @ 2.10GHz                                                            |
| NVRAM             | Intel Optane DC Persistent Memory Gen 1, 2666 MHz, 128 GiB per DIMM, 6 DIMM per CPU                 |
| NVRAM Firmware    | 01.02.00.5355                                                                                       |
| OS                | Ubuntu 20.04.4 LTS                                                                                  |
| Kernel            | Linux 5.4.0-110-generic #124-Ubuntu SMP Thu Apr 14 19:46:19 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux |
| GCC               | 9.4.0-1ubuntu1~20.04.1                                                                              |
| ipmctl            | Intel(R) Optane(TM) Persistent Memory Command Line Interface Version 02.00.00.3885                  |
| ndctl             | 67+                                                                                                 |

## Install required Optane management tools

1. Install `ipmctl`
2. Install `ndctl`

> These tools are pre-installed on the machine we provided to Usenix Security 23 AE committee.

## Set up project root path environment

NVLeak uses a shell env `PROJ_ROOT` to point to the root path of the NVLeak, i.e., it assumes `$PROJ_ROOT/NVLeak` is the NVLeak repo.

The default value of `PROJ_ROOT` is `/home/usenix` and you may set the global env var to override it by:

```shell
export PROJ_ROOT=/path/to/your/project/root/
```

## Get the code

On the *NVRAM Server*, run the following lines to get the NVLeak code and initialize the project:

```shell
$ git clone https://github.com/TheNetAdmin/NVLeak.git
$ cd NVLeak
$ git submodule update --init --recursive
$ bash nvleak/script/configure/nvleak.sh
```

## Configure the NVRAM Server environment

> NVLeak contains a kernel module which is compatible with Linux 5.4.0 (we previously compiled it on Linux 4.15 and 5.1). Newer Linux kernel may have breaking changes to filesystem APIs that NVLeak relies on, and thus may break the compilation.

We provide a set of scripts to automatically configure the Linux environment. These scripts check for the host name and set up the environments accordingly. You may need to modify the scripts under `nvleak/scripts/machine` to use them on your machine, specifically, you need to modify:

   1. `nvleak/scripts/batch/default_config.sh`: To add your NVRAM machine's system and hardware info for reverse engineering tools
   2. `nvleak/scripts/machine/grub.sh`: To update the kernel names on your machine and add your gurb settings
   3. `nvleak/user/side_channel/common.sh`: To add your environment's device names and tool path

### Set up the environment using scripts

> This set up process involves several rounds of machine rebooting.

Log in to the NVRAM Server and:

1. Log in to the root user as the scripts implicitly assume they run with the sudo privilege (assuming username is `usenix`):

   ```shell
   $ sudo -i su
   $ cd $PROJ_ROOT/NVLeak
   ```

2. Set up the kernel boot command and reboot

   ```shell
   $ bash nvleak/scripts/machine/machine.sh setup
   # When prompting "Do you want to continue? [y/n]", enter "y" to continue
   $ reboot now
   # After reboot, check the kernel arguments
   $ cat /proc/cmdline
   BOOT_IMAGE=/vmlinuz-5.4.0-110-generic root=... ro nokaslr memmap=32G!16G log-buf-len=1G mitigations=off
   ```

3. Turn off SMT through BIOS or using the script:

   ```shell
   $ bash nvleak/scripts/machine/smt.sh
   ```

4. Configure the Optane DIMMs into non-interleaved mode

   ```shell
   # When prompting "Do you want to continue? [y/n]", enter "y" to continue
   $ sudo bash nvleak/scripts/machine/optane.sh reset
   $ sudo bash nvleak/scripts/machine/optane.sh setup appdirect ni
   $ reboot now
   # Create pmem devices
   $ sudo bash nvleak/scripts/machine/optane.sh ndctl
   # Check the created devices, make sure there are two devices:
   #   - pmem0 is created by kernel argument `memmap` on a DRAM region
   #   - pmem1 is the first available non-interleaved Optane DIMM, and size is a single DIMM size
   $ ndctl list -u
   [
     {
       "dev":"namespace1.0",
       "mode":"fsdax",
       "map":"dev",
       "size":"124.03 GiB (133.18 GB)",
       "uuid":"***",
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

5. Set up git safe dir to run `git` under git submodule dirs

   ```shell
   $ sudo -i su
   
   # Check Check if git runs fine under submodule dir
   $ git status
   fatal: unsafe repository ('/home/usenix/NVLeak/nvleak' is owned by someone else)
   ...
   # If you do not see the above error message, then try `git diff`,
   # and if `git diff` works fine, then you can skip the following `git config`

   $ git config --global --add safe.directory $PROJ_ROOT/NVLeak/nvleak

   # Check if git runs fine now under submodule dir
   $ cd $PROJ_ROOT/NVLeak/nvleak
   $ git status
   ...
   nothing to commit, working tree clean
   ```

6. Install additional tools

   ```shell
   $ sudo apt install jq
   ```
