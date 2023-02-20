`ifndef __SIMULATION_SVH__
`define __SIMULATION_SVH__

`timescale 1ns/100ps
`define CLOCK_PERIOD (40) // ns

`define TEST_OUT_FILE "out/tb_test.txt"

`ifdef SIM_DEBUG

`define FOPEN(name) \
		fd = $fopen(name, "w");
`define FCLOSE() \
		if (fd) begin \
			$fclose(fd); \
		end
`define FWRITE(args) \
		if (fd) begin \
			$fdisplay(fd, {$sformatf args}); \
		end

`else // SIM_DEBUG

`define FOPEN(name)
`define FCLOSE()
`define FWRITE(args)

`endif // SIM_DEBUG

`ifdef SIM_TESTS

`define STOP() \
		$finish;

`else // SIM_TESTS

`define STOP() \
		$stop;

`endif // SIM_TESTS

`endif // __SIMULATION_SVH__
