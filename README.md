## About

This is a framework for microarchitecture tracing. It allows instructors and learners to run real world processor cores in a simulation and tracing environment that abstracts from design details and captures the relevant microarchitectural details instead.

It uses [pipeline-viewer](https://pypi.org/project/pipelineviewer/) to visualize the microarchitectural details.

## Getting started

Clone the repository and the cores:

```bash
git clone --recursive https://github.com/hm-riscv/microarchtrace
```

Install the Python3 prerequisites:

```bash
pip3 install -r requirements.txt
```

You also need to install [Verilator](https://www.veripool.org/verilator/) and a build environment.

For each core you can find a quick start and potential lab assignments in their respective folder in `cores/`.

### Cores and their status

- [Ibex Core](cores/ibex/)
- [SWERV EL2](cores/swerv-el2)
- [SWERV EH1](cores/swerv-eh1)

