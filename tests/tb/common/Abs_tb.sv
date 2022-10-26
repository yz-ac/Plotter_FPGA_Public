`include "../../../src/common/common.svh"

module Abs_tb;

	localparam BITS = `BYTE_BITS;

	reg [BITS-1:0] in;
	
	wire [BITS-2:0] out;

	Abs #(
		.BITS(BITS)
	) UUT (
		.in(in),
		.out(out)
	);

	// 12 clks
	initial begin
		in = 3;
		#(`CLOCK_PERIOD * 4);

		in = -8;
		#(`CLOCK_PERIOD * 4);

		in = 0;
		#(`CLOCK_PERIOD * 4);
	end

endmodule : Abs_tb
