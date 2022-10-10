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

1. Set up the NVRAM Server environment following the [instructions](./SetUpNVRAM.md)
2. Set up the Dev Server environment following the [instructions](./SetUpDev.md)