`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, num: %d, is_valid: %d", $time, num, is_valid))

module ArgSizeCheck_tb;
	int fd;

	localparam MAX_ARG_BITS = `OP_ARG_BITS;
	localparam NUM_BITS = MAX_ARG_BITS * 2;

	reg [NUM_BITS-1:0] num;
	wire is_valid;

	ArgSizeCheck #(
		.MAX_ARG_BITS(MAX_ARG_BITS)
	) UUT (
		.num(num),
		.is_valid(is_valid)
	);

	initial begin
		`FOPEN("tests/tests/ArgSizeCheck_tb.txt")

		num = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = 100;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = -100;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = 2047;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = -2048;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = 2048;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = -2049;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = 4096;
		#(`CLOCK_PERIOD * 2);
		`LOG

		num = 8192;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : ArgSizeCheck_tb
