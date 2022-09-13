`include "../../../src/common/common.svh"

module Counter_tb;

	localparam CLK_EN_BITS = `BYTE_BITS;
	localparam COUNTER_BITS = `NIBBLE_BITS;

	reg clk;
	reg reset;
	reg enable;

	wire clk_en;
	wire [COUNTER_BITS-1:0] out;

	ClockEnabler #(
		.PERIOD_BITS(CLK_EN_BITS)
	) clock_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(2),
		.out(clk_en)
	);

	Counter #(
		.COUNTER_BITS(COUNTER_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.enable(enable),
		.out(out)
	);

	always begin
		clk = 1;
		#(`CLOCK_PERIOD / 2);
		clk = 0;
		#(`CLOCK_PERIOD / 2);
	end

	// 72 clks
	initial begin
		reset = 1;
		enable = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		#(`CLOCK_PERIOD * 50);

		enable = 0;
		#(`CLOCK_PERIOD * 10);

		enable = 1;
		#(`CLOCK_PERIOD * 10);
	end

endmodule : Counter_tb;
