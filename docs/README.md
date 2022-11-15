# NVLeak

## Introduction

### Experimental environments

Our USENIX Security paper evaluates two server machines equipped with Intel Optane DC Persistent Memory Gen 1, aka Apache Pass. To reproduce our results, we suggest to use Gen 1 Intel Optane DIMM as later generations may have changed their microarchitecture designs.

We set Intel Optane DIMMs in non-interleaved mode and use only one of them for our experiments, so an Intel server machine with at least one Intel Optane DIMM Gen 1 is required to reproduce our results.

We also provide a set of scripts to parse results and generate plots. These scripts do not need to run on the server with Optane DIMM, i.e., they can run on any Linux environment (e.g., your local workstation or laptop).

### Terms

In the remaining doc, we use the following terms:

- **NVRAM Server:** The Intel server machine equipped with Intel Optane DIMM.
- **Dev Server:** The machine that runs scripts to parse results and generate plots. It can be any Linux environment such as your laptop or workstation. It's not preferred to use the *NVRAM Server* to run these scripts because they run some Docker containers (e.g., MongoDB) which might create noises to the experiment results.

## Set up environments

1. Set up the NVRAM Server environment following the [instructions](./setup/NVRAMServer.md)
2. Set up the Dev Server environment following the [instructions](./setup/DevServer.md)

## Run experiments on the NVRAM Server

The major claims of our [USENIX Security 23 paper](./usenix23-nvleak.pdf) are listed below:

> In our main paper, Figure 2 to 17 are from the Server A (see Table 1 in the main paper) and Figure 18 is from the Server B and it's from the same experiments as Figure 4-7.

| Figure # | Type                | Description                                                 |
| :------- | :------------------ | :---------------------------------------------------------- |
| 2        | Reverse Engineering | Recover L1/L2 NVCache sizes and their block sizes           |
| 4        | Reverse Engineering | Recover L1/L2 NVCache set structures                        |
| 5        | Reverse Engineering | Recover the wear-leveling policy                            |
| 6        | Reverse Engineering | Recover the wear-leveling's trigger condition               |
| 7        | Reverse Engineering | Recover the robustness of wear-leveling data migration      |
| 9b & 9c  | Covert Channel      | Cross virtual machine covert channel performance and signal |
| 10       | Covert Channel      | Filesystem inode-based covert channel                       |
| 12       | Side Channel        | Access patterns of SQLite executing different SQL code      |
| 13       | Side Channel        | Access patterns of SQLite executing ranged queries          |
| 14       | Side Channel        | Access patterns of PMDK key-value store                     |
| 15       | Side Channel        | Detected function calls from wolfSSL library                |
| 16       | Mitigation          | Effectiveness and performance of the PMDK-based mitigation  |
| 17       | Reverse Engineering | Detailed pointer chasing results on Server A                |
| 18       | Reverse Engineering | Reverse engineering results on Server B                     |

> NOTE: Reproducing the full results can take up **60 GiB** of your disk space to store the result data. Please pre-allocate this disk space, or incrementally reproduce the results and delete the data once the result is reproduced.

To reproduce these results, see the following instructions:

1. To reproduce reverse engineering results (Figure 2-7 and 17), follow [this instruction](./reproduce/ReverseEngineering.md).
2. To reproduce covert channel results (Figure 9-10), follow [this instruction](./reproduce/CovertChannel.md)
3. To reproduce side channel results (Figure 12-15), follow [this instruction](./reproduce/SideChannel.md)
4. To reproduce the mitigation result (Figure 16), follow [this instruction](./reproduce/Mitigation.md)

The estimated resources it takes to reproduce results:

| Experiments         | Human Hour | Compute Hour | Disk Space |
| :------------------ | ---------: | -----------: | ---------: |
| Reverse Engineering |        1~2 |            6 |   > 18 GiB |
| Covert Channel      |        1~2 |           16 |     32 GiB |
| Side Channel        |        2~4 |            1 |      1 GiB |
| Mitigations         |        2~3 |            1 |      1 GiB |
