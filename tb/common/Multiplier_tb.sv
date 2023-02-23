`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, num_in: %d, num_out: %d", $time, num_in, num_out))

module Multiplier_tb;
	int fd;

	localparam NUM_IN_BITS = `BYTE_BITS;
	localparam MULT_BITS = `BYTE_BITS;
	localparam NUM_OUT_BITS = NUM_IN_BITS + MULT_BITS - 1;

	reg [NUM_IN_BITS-1:0] num_in;
	reg [MULT_BITS-1:0] mult;
	wire [NUM_OUT_BITS-1:0] num_out;

	Multiplier #(
		.NUM_IN_BITS(NUM_IN_BITS),
		.MULT_BITS(MULT_BITS)
	) UUT (
		.num_in(num_in),
		.mult(mult),
		.num_out(num_out)
	);

	initial begin
		`FOPEN("tests/tests/Multiplier_tb.txt")

		mult = 2;
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
