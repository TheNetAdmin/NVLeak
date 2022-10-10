# Reproduce Reverse Engineering Results

Before running the experiments described in this document, you should first set up the NVRAM Server following [this instruction](../SetUpNVRAM.md).

## Build NVLeak and set up the PMEM devices

Install build dependencies if not already installed

```shell
$ sudo apt install build-essential gcc linux-headers-$(uname -r)
```

Build NVLeak with following commands

```shell
$ cd nvleak/src
$ make -j $(nproc)

# Check the generated kernel modules
$ file latfs.ko repfs.ko
latfs.ko: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), BuildID[sha1]=***, not stripped
repfs.ko: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), BuildID[sha1]=***, not stripped
```

Try to load these kernel modules and then unload them, to see if they work properly

```shell
$ sudo -i su
$ cd /home/usenix/NVLeak/nvleak

# Set up PMEM devices and mount kernel modules
# Assume the /dev/pmem0 is DRAM and /dev/pmem1 is NVRAM
$ export dram_dev="/dev/pmem0"
$ export nvram_dev="/dev/pmem1"
$ ./utils/mount.sh "${dram_dev}" "${nvram_dev}"

# Check if kernel modules are working properly
$ cat /proc/lens
LENS task=<task> op=<op> [options]
Tasks:
        1: Basic Latency Test (not configurable)
        2: Strided Latency Test  [access_size] [stride_size]
        3: Strided Bandwidth Test [access_size] [stride_size] [delay] [parallel] [runtime] [global]
...
Available pointer chasing back and forth benchmarks:
        No.     Name                    Block Size (Byte)
        0       pointer-chasing-baf-64  64
        1       pointer-chasing-baf-128 128
        2       pointer-chasing-baf-256 256
        3       pointer-chasing-baf-512 512
        4       pointer-chasing-baf-1024        1024
        5       pointer-chasing-baf-2048        2048
        6       pointer-chasing-baf-4096        4096

# Unload kernel modules
$ ./utils/umount.sh
```

Then build the LENS following the above commands, the only difference is that instead of `NVLeak/nvleak`, this time navigate to `NVLeak/lens` to build results.

## Figure 2: Pointer chasing latencies and amplification factors

1. Run experiments on the NVRAM Server

   ```shell
   # Experiments typically take minutes to hours to run, so execute them in tmux
   $ tmux
   
   # Experiments assume sudo permission so log in to the root user.
   # Note: executing scripts with `sudo` command does NOT work properly, so log in to root instead
   $ sudo -i su
   $ cd /home/usenix/NVLeak/lens

   $ cd scripts
   # dram_dev and nvram_dev values are set up in the previous section
   $ bash lens.sh "${dram_dev}" "${nvram_dev}" prober/buffer/pointer_chasing.sh read_and_write
   # When prompting "Press any key to start, or Ctrl-C to exit...", press Enter to proceed
   # This experiment takes ~9mins to run on our NVRAM Server

   # Check the results, note the double dash in the folder name
   $ ls ../results/tasks
   nv-4-20221010003505

   $ export fig2_result="nv-4-20221010003505"
   
   # Briefly check if the output has valid results, you should see many lines of outputs similar to those shown here
   $ cat ../results/tasks/${fig2_result}/stdout.log
   [2022-10-09 23:00:16] task=7,pc_region_size=64,pc_block_size=64,message=nv-4-7-64-64
   [2022-10-09 23:00:21] [22805.924667] {0}[pointer-chasing-64] region_size 64, block_size 64, count 8388608, total 3630625426 ns, average 432 ns, cycle 4385177151111378 - 4385180127968010 - 4385184757521846, fence_strategy mfence, fence_freq region.
   ```

2. Parse results on the NVRAM Server

   ```shell
   $ cd ../results/tasks/${fig2_result}
   $ python3 ../../../scripts/prober/buffer/parse.py pointer-chasing \
             --src_file ./stdout.log \
             --out_file ./pointer_chasing.csv \
     ;
   ```

   The above commands generate the parsed data `pointer_chasing.csv`

3. Collect results on the Dev Server

   ```shell
   # On your Dev Server, collect results from the NVRAM Server
   $ ssh dev_server
   $ cd NVLeak/report

   # Copy results from NVRAM Server to Dev Server
   # Note: fig2_result is previously defined on the NVRAM Server,
   #       you should define it again on the Dev Server,
   #       or replace with the task ID you get in previous steps
   $ cd data/reproduce/fig2
   $ scp nvram_server:/home/usenix/NVLeak/lens/results/${fig2_result}/pointer_chasing.csv .
   ```
