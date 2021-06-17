## Getting started

The ibex core has more Python requirements you need to install:

```bash
pip install -r sources/python-requirements.txt
```

First builds the simulation and tracing:

```bash
make build
```

You then need to build software for the ibex core (see examples).

Then execute the software and load it to the processor core.

```bash
./build/hm_microarchtrace_ibex_0/sim-verilator/Vibex_simple_system --raminit=<your-program>.vmem```
```

Finally, inspect the software execution using `pipeline-viewer`:

```bash
pipeline-viewer ibex trace
```