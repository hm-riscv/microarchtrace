
build:
	fusesoc --cores-root=. run --target=sim --setup --build hm:microarchtrace:ibex $(BUILD_ARG)

run: sources/examples/sw/simple_system/hello_test/hello_test.vmem
	./build/hm_microarchtrace_ibex_0/sim-verilator/Vibex_simple_system --raminit=sources/examples/sw/simple_system/hello_test/hello_test.vmem

sources/examples/sw/simple_system/hello_test/hello_test.vmem:
	make -C sources/examples/sw/simple_system/hello_test/ hello_test.vmem

.PHONY: build run
