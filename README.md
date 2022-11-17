# NVLeak

This repo contains artifacts for our USENIX Security '23 paper *NVLeak: Off-Chip Side-Channel Attacks via Non-Volatile Memory Systems*.

## Overview

This repo contains all code and tools to reproduce results in our paper, as well as data parsing and plotting scripts to generate result graph.

The repo directory structure:

```shell
.
├── data       # Raw data copied from the NVRAM machine
├── docker     # MongoDB docker image for data parsing scripts
├── docs       # Docs to build and run NVLeak, and reproduce results
├── lens       # Original version of LENS to reproduce part of results in the paper
├── nvleak     # NVLeak code: reverse engineering, cover/side channel, mitigation, runner scripts
├── report     # LaTeX template and R scripts to plot results and generate a pdf report
└── scripts    # Data fetching and parsing scripts
```

The high-level process of reproducing NVLeak results involves the following steps:

  1. Run `lens` and `nvleak` code on the NVRAM machine
  2. Fetch data from NVRAM machine to local develop machine's `data` dir
  3. Start the docker image and parse data using `scripts`
  4. Link `data` to `report`, plot results and generate a PDF report

See more detailed [docs](./docs/README.md) to use NVLeak and reproduce results.

## NVLeak overview

The NVLeak sub-repo has the following structure

```shell
.
├── docs    # Docs for setting up vscode   
├── scripts # Various helper scripts such as grub setup and NVRAM configurations
├── src     # Reverse engineering suite implementation
└── user    # User space covert/side channel and mitigations implementations
    ├── covert_channel
    │   ├── cross_vm             # Cross-VM covert channel
    │   └── inode                # Filesystem inode-based covert channel
    └── side_channel
        ├── bench.sh             # Helper functions for side channel demos
        ├── common.sh            # Common env vars for side channel demos
        ├── data                 # Database dataset
        ├── libpmemobj-cpp       # PMDK library
        ├── map_cli              # PMDK's key-value store side channel
        ├── mitigation_benchmark # PMDK benchmarks to evaluate mitigation performance
        ├── nvleak               # Side channel attacker code
        ├── select_runner.sh     # Helper functions for side channel demos
        ├── setup                # NVRAM set up functions
        ├── shared_lib           # Shared library side channel demos
        ├── sqlite               # SQLite side channel demos
        └── wolfssl              # wolfSSL side channel demos
```

## Cite NVLeak

``` BibTeX
@inproceedings{Wang2023NVLeak,
  title     = {{NVLeak}: Off-Chip Side-Channel Attacks via Non-Volatile Memory Systems},
  author    = {Zixuan Wang and Mohammadkazem Taram and Daniel Moghimi and Steven Swanson and Dean Tullsen and Jishen Zhao},
  booktitle = {32nd {USENIX} Security Symposium ({USENIX} Security 23)},
  year      = {2023}
}
```

## License

The code is distributed under MIT license unless otherwise stated under sub folders.
