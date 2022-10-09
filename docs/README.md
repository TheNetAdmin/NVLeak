# NVLeak

# Introduction

## Experimental environments

Our USENIX Security paper evaluates two server machines equipped with Intel Optane DC Persistent Memory Gen 1, aka Apache Pass. To reproduce our results, we suggest to use Gen 1 Intel Optane DIMM as later generations may have changed their microarchitecture designs.

We set Intel Optane DIMMs in non-interleaved mode and use only one of them for our experiments, so an Intel server machine with at least one Intel Optane DIMM Gen 1 is required to reproduce our results.

We also provide a set of scripts to parse results and generate plots. These scripts do not need to run on the server with Optane DIMM, i.e., they can run on any Linux environment (e.g., your local workstation or laptop).

## Terms

In the remaining doc, we use the following terms:

- **NVRAM Server:** The Intel server machine equipped with Intel Optane DIMM.
- **Dev Server:** The machine that runs scripts to parse results and generate plots. It can be any Linux environment such as your laptop or workstation. It's not preferred to use the *NVRAM Server* to run these scripts because they run some Docker containers (e.g., MongoDB) which might create noises to the experiment results.

# Set up the NVRAM Server

## Get the code

On the *NVRAM Server*, run the following lines to get the NVLeak code:

```shell
$ git clone https://github.com/TheNetAdmin/NVLeak.git
$ cd NVLeak
$ git submodule init
$ git submodule update --recursive
```

## Configure the NVRAM Server environment

> NVLeak contains a kernel module which is compatible with Linux 5.4.0 (we previously compiled it on Linux 4.15 and 5.1). Newer Linux kernel may have breaking changes to filesystem APIs that NVLeak relies on, and thus may break the compilation.

We provide a set of scripts to automatically configure the Linux environment. These scripts check for the host name and set up the environments accordingly. You may need to modify the scripts under `nvleak/scripts/machine` to use them on your machine, or alternatively you can manually set up the environments as described later in this doc.

### Set up the environment using scripts

> This set up process involves several rounds of machine rebooting.

Log in to the NVRAM Server and:

1. Log in to the root user as the scripts implicitly assume they run with the sudo priviledge:
   ```shell
   $ sudo su -i
   $ cd $NVLeak_Code_Path
   ```
2. Set up the kernel boot command and reboot
   ```shell
   $ bash scripts/machine/machine.sh setup
   $ reboot now
   # After reboot, check the kernel arguments
   $ cat /proc/cmdline
   BOOT_IMAGE=/vmlinuz-5.4.0-110-generic root=... ro nokaslr memmap=32G!16G log-buf-len=1G mitigations=off
   ```
3. 