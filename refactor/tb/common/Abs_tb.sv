`include "common/common.svh"
`include "tb/simulation.svh"

module Abs_tb;

	localparam NUM_BITS = `BYTE_BITS;

	reg [NUM_BITS-1:0] num;

	wire [NUM_BITS-2:0] out;

	Abs #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.num(num),
		.out(out)
	);

	initial begin
		num = -3;
		#(`CLOCK_PERIOD * 2);

		num = 3;
		#(`CLOCK_PERIOD * 2)

		num = -5;
		#(`CLOCK_PERIOD * 2)

		$stop;
	end // initial

endmodule : Abs_tb
