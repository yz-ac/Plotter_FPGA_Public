`include "tb/simulation.svh"
`include "common/common.svh"

module Abs_tb;

	int fd;

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
		`FOPEN("tests/tests/Abs_tb.txt")

		num = -3;
		#(`CLOCK_PERIOD * 2);
		`FWRITE(("in: %d, out: %d", num, out))

		num = 3;
		#(`CLOCK_PERIOD * 2)
		`FWRITE(("in: %d, out: %d", num, out))

		num = -5;
		#(`CLOCK_PERIOD * 2)
		`FWRITE(("in: %d, out: %d", num, out))

		`FCLOSE
		`STOP
	end // initial

endmodule : Abs_tb
