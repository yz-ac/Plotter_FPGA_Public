`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, num_in: %d, num_out: %d", $time, num_in, num_out))

module Multiplier_tb;
	int fd;

	localparam NUM_IN_BITS = `BYTE_BITS;
	localparam NUM_MULT = 2;
	localparam NUM_OUT_BITS = NUM_IN_BITS + $clog2(NUM_MULT);

	reg [NUM_IN_BITS-1:0] num_in;
	wire [NUM_OUT_BITS-1:0] num_out;

	Multiplier #(
		.NUM_IN_BITS(NUM_IN_BITS),
		.NUM_MULT(NUM_MULT)
	) UUT (
		.num_in(num_in),
		.num_out(num_out)
	);

	initial begin
		`FOPEN("tests/tests/Multiplier_tb.txt")

		num_in = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num_in = 3;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num_in = -5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num_in = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : Multiplier_tb
