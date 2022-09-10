`include "../../../src/common/common.svh"

module ClockEnabler_tb;

	localparam PERIOD_BITS = `BYTE_BITS;

	reg clk;
	reg reset;
	reg enable;
	reg [PERIOD_BITS-1:0] period;

	wire out;

	ClockEnabler #(
		.PERIOD_BITS(PERIOD_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.period(period),
		.out(out)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 94 clocks
	initial begin
		reset = 1;
		enable = 1;
		period = 3;

		#(`CLOCK_PERIOD * 2);

		reset = 0;
		#(`CLOCK_PERIOD * 32);

		period = 5;
		#(`CLOCK_PERIOD * 50);

		period = 0;
		#(`CLOCK_PERIOD * 10);
	end

endmodule : ClockEnabler_tb
