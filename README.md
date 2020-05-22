## Getting started

Clone the repository and the cores:

```bash
git clone --recursive https://github.com/hm-riscv/microarchtrace
```

### Ibex Core

Go to directory:

```bash
cd cores/ibex
```

Build the simulation:

```bash
make build
```

Run the simulation with the hello test:

```bash
make run
```

Potentially you need to set the compiler to your RISC-V compiler:

```bash
make run CC=riscv64-unknown-elf-gcc
```

Inspect the microarchitecture trace:

```bash
babeltrace trace/
```
