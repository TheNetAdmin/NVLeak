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

### Figure 2a

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

   $ export fig2a_result="nv-4-20221010003505"
   
   # Briefly check if the output has valid results, you should see many lines of outputs similar to those shown here
   $ cat ../results/tasks/${fig2a_result}/stdout.log
   [2022-10-09 23:00:16] task=7,pc_region_size=64,pc_block_size=64,message=nv-4-7-64-64
   [2022-10-09 23:00:21] [22805.924667] {0}[pointer-chasing-64] region_size 64, block_size 64, count 8388608, total 3630625426 ns, average 432 ns, cycle 4385177151111378 - 4385180127968010 - 4385184757521846, fence_strategy mfence, fence_freq region.
   ```

2. Parse results on the NVRAM Server

   ```shell
   $ cd ../results/tasks/${fig2a_result}
   $ python3 ../../scripts/prober/buffer/parse.py pointer-chasing \
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
   # Note: fig2a_result is previously defined on the NVRAM Server,
   #       you should define it again on the Dev Server,
   #       or replace with the task ID you get in previous steps
   $ cd data/reproduce/fig2
   $ scp nvram_server:/home/usenix/NVLeak/lens/results/${fig2a_result}/pointer_chasing.csv .
   ```

4. Update the report and generate plots

   ```shell
   # On the Dev Server
   $ cd NVLeak/report

   # Uncomment the line starting with '#reproduce/fig2a-pointer-chasing', by removing the initial '#'
   # This configures NAP to automatically generate corresponding plots
   $ sed -i 's/\#reproduce\/fig2a-pointer-chasing/reproduce\/fig2a-pointer-chasing /g' figure/plots.csv

   # Edit the `figure/2.tex` to uncomment the Fig 2a reproduced result and remove the placeholder
   $ vim content/figure/2.tex
   $ git diff content/figure/2.tex
   -        % \resizebox{\textwidth}{!}{\includegraphics{figure/plot/reproduce/fig2a-pointer-chasing.tikz.pdf}}
   -        \resizebox{\textwidth}{!}{\includegraphics{example-image-duck}}
   +        \resizebox{\textwidth}{!}{\includegraphics{figure/plot/reproduce/fig2a-pointer-chasing.tikz.pdf}}
   +        % \resizebox{\textwidth}{!}{\includegraphics{example-image-duck}}

   # Generate the updated report `paper.pdf` and compare the plots
   $ make
   ```

### Figure 2b

1. Run experiments on the NVRAM Server

   ```shell
   $ sudo -i su
   $ cd /home/usenix/NVLeak/lens/scripts
   $ bash lens.sh "${dram_dev}" "${nvram_dev}" prober/buffer/amplification.sh
   $ ls ../results/tasks
   nv-4-20221010010029

   $ export fig2b_result="nv-4-20221010010029"
   ```

2. Parse results on the NVRAM Server

   ```shell
   $ cd ../results/tasks/${fig2b_result}
   $ python3 ../../scripts/prober/buffer/parse.py amplification \
             --src_file ./stdout.log \
             --out_file ./amplification.csv \
     ;
   ```

   The above commands generate the parsed data `amplification.csv`, a sample output (the original output's csv fields are not aligned as follows):

   ```csv
   block_size ,rmw_buf_read_amp   ,ait_buf_read_amp   ,lsq_write_amp      ,wpq_write_amp
           64 ,1.8419977250158328 ,1.1825545631690741 ,4.3491405740983735 ,3.7866680695940786
          256 ,1.0082785254933768 ,1.172073928014756  ,1.0991160886255633 ,1.0724346830696088
          512 ,1.0077587690030065 ,1.1172805433470596 ,1.092708215636445  ,1
         1024 ,0.9902864923555564 ,1.0711492079967622 ,1.0518556773340084 ,1
         2048 ,0.975020188407263  ,1.0345758151716147 ,1.0118591525367049 ,1
         4096 ,0.9676126480736705 ,1.0012261133728872 ,1.0117095136951986 ,1
   ```

3. Update the report and generate plots

   ```shell
   # On the Dev Server
   $ cd NVLeak/report

   # Edit the `figure/2.tex` to update the Fig 2b table's reproduced data
   $ vim content/figure/2.tex
   # Fill the table with results from the `amplification.csv` from step 2
   # NOTE: the column names and you should ignore the `lsq_write_amp` column

   # Generate the updated report `paper.pdf` and compare the plots
   $ make
   ```
