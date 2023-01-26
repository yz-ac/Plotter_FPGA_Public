`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, digit: %d, is_negative: %d, num: %d", $time, digit, is_negative, num))

module NumberBuilder_tb;
	int fd;

	localparam NUM_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	reg zero;
	reg is_negative;
	reg [`DIGIT_BITS-1:0] digit;
	reg advance;
	wire [NUM_BITS-1:0] num;

	SimClock sim_clk (
		.out(clk)
	);

	NumberBuilder #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.zero(zero),
		.is_negative(is_negative),
		.digit(digit),
		.advance(advance),
		.num(num)
	);

	initial begin
		`FOPEN("tests/tests/NumberBuilder_tb.txt")

		reset = 1;
		zero = 0;
		is_negative = 0;
		advance = 0;
		digit = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		reset = 0;
		digit = 3;
		advance = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		advance = 1;
		#(`CLOCK_PERIOD);
		`LOG

		advance = 0;
		#(`CLOCK_PERIOD);
		`LOG

		digit = 7;
		advance = 1;
		#(`CLOCK_PERIOD);
		`LOG

		advance = 0;
		zero = 1;
		#(`CLOCK_PERIOD);
		`LOG

		zero = 0;
		digit = 1;
		advance = 1;
		#(`CLOCK_PERIOD);
		`LOG

		advance = 0;
		#(`CLOCK_PERIOD);
		`LOG

		digit = 0;
		advance = 1;
		#(`CLOCK_PERIOD);
		`LOG

		advance = 0;
		#(`CLOCK_PERIOD);
		`LOG

		digit = 3;
		advance = 1;
		#(`CLOCK_PERIOD);
		`LOG

		advance = 0;
		#(`CLOCK_PERIOD);
		`LOG

		is_negative = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : NumberBuilder_tb
