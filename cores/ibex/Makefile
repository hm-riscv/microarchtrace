
build:
	fusesoc --cores-root=. run --target=sim --setup --build hm:microarchtrace:ibex $(BUILD_ARG)

run: sw/hello_test/hello_test.vmem
	./build/hm_microarchtrace_ibex_0/sim-verilator/Vibex_simple_system --raminit=sw/hello_test/hello_test.vmem

sw/hello_test/hello_test.vmem:
	make -C sw/hello_test/ hello_test.vmem

.PHONY: build run
