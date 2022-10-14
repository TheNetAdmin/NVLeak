# Set up the NVRAM Server

## Install required Optane management tools

1. Install `ipmctl`
2. Install `ndctl`

> These tools are pre-installed on the machine we provided to Usenix Security 23 AE committee.

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

We provide a set of scripts to automatically configure the Linux environment. These scripts check for the host name and set up the environments accordingly. You may need to modify the scripts under `nvleak/scripts/machine` to use them on your machine, or alternatively you can manually set up the environments as described later in this doc.

### Set up the environment using scripts

> This set up process involves several rounds of machine rebooting.

Log in to the NVRAM Server and:

1. Log in to the root user as the scripts implicitly assume they run with the sudo priviledge (assuming username is `usenix`):

   ```shell
   $ sudo -i su
   $ cd /home/usenix/NVLeak
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

   $ git config --global --add safe.directory /home/usenix/NVLeak/nvleak

   # Check if git runs fine now under submodule dir
   $ cd /home/usenix/NVLeak/nvleak
   $ git status
   ...
   nothing to commit, working tree clean
   ```

6. Install additional tools

   ```shell
   $ sudo apt install jq
   ```

### Manually set up the environments

> TODO: To be added
