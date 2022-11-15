# Reproduce Mitigation Results

## Build Dependencies and Configure Optane DIMMs

Follow the instruction of [PMDK Side Channel](./SideChannel.md#reproduce-pmdk-side-channel-figure-14) to build PMDK libpmem-obj library and configure Optane DIMMs.

## Run Mitigation Effectiveness Evaluation (Figure 16 a-b)

```shell
$ sudo -i su
$ cd $PROJ_ROOT/NVLeak/nvleak/user/side_channel/map_cli

# Run experiments for Fig 16a
$ ./run.sh # Select "2) ./runners/2_read_only.sh"

# Run experiments for Fig 16b
$ ./run.sh # Select "6) ./runners/6_read_only_secure.sh"
```

## Run Mitigation Performance Evaluation (Figure 16 c)

```shell
$ cd $PROJ_ROOT/NVLeak/nvleak/user/side_channel/mitigation_benchmark
$ bash setup.sh
$ bash run_all.sh
```

## Collect Mitigation Results and Generate Plots

On your Dev Server, fetch the results and generate plots.

```shell
$ cd NVLeak/data
$ bash copy.sh # Or manually copy the results from NVRAM Server to Dev Server

# Parse results
$ cd NVLeak/data/mitigation_benchmark/results
$ python3 ../../../scripts/mitigation/parse.py .
$ cat performance.csv # check the output file

$ cd NVLeak/report/data/reproduce/fig16/
$ vim fetch.sh
$ bash fetch.sh

$ cd NVLeak/report/
$ sed -i 's/\#reproduce\/fig16/reproduce\/fig16/g' figure/plots.csv
$ vim content/figure/16.tex # uncomment the 'reproduce' sub figures
$ make # generate the report 'paper.pdf'
```