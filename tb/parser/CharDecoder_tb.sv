`include "tb/simulation.svh"
`include "common/common.svh"

import Char_PKG::Char_t;

`define LOG() \
		`FWRITE(("time: %t, char_in: %c, char_type: %d", $time, char_in, char_type))

module CharDecoder_tb;
	int fd;

	reg [`BYTE_BITS-1:0] char_in;
	Char_t char_type;

	CharDecoder UUT (
		.char_in(char_in),
		.char_type(char_type)
	);

	initial begin
		`FOPEN("tests/tests/CharDecoder_tb.txt")

		char_in = 71; // 'G'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 52; // '4'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 45; // '-'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 88; // 'X'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 89; // 'Y'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 73; // 'I'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 74; // 'J'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 32; // ' '
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 46; // '.'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 10; // '\n'
		#(`CLOCK_PERIOD * 2);
		`LOG

		char_in = 70; // 'F'
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : CharDecoder_tb
