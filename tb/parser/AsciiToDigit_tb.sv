`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, char_in: %c, digit_out: %d", $time, char_in, digit_out))

module AsciiToDigit_tb;
	int fd;

	reg [`BYTE_BITS-1:0] char_in;
	wire [`DIGIT_BITS-1:0] digit_out;

	AsciiToDigit UUT (
		.char_in(char_in),
		.digit_out(digit_out)
	);

	initial begin
		`FOPEN("tests/tests/AsciiToDigit_tb.txt")

		char_in = 'h30;
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 'h35;
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 'h37;
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 'h32;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : AsciiToDigit_tb
