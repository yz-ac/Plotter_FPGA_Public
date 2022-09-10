`include "../../../src/common/common.svh"

module Pwm_tb;

	localparam CLK_EN_BITS = `BYTE_BITS;
	localparam PERIOD_BITS = `BYTE_BITS;

	reg clk;
	reg reset;
	reg [PERIOD_BITS-1:0] period;
	reg [PERIOD_BITS-1:0] duty_cycle;

	wire clk_en;
	wire out;

	ClockEnabler #(
		.PERIOD_BITS(CLK_EN_BITS)
	) clk_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(2),
		.out(clk_en)
	);

	Pwm #(
		.PERIOD_BITS(PERIOD_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.period(period),
		.duty_cycle(duty_cycle),
		.out(out)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 122 clks
	initial begin
		reset = 1;
		period = 5;
		duty_cycle = 2;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		#(`CLOCK_PERIOD * 23);

		duty_cycle = 3;
		#(`CLOCK_PERIOD * 23);

		duty_cycle = 6;
		#(`CLOCK_PERIOD * 23);

		period = 7;
		#(`CLOCK_PERIOD * 31);

		period = 0;
		#(`CLOCK_PERIOD * 20);
	end

endmodule : Pwm_tb
