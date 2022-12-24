`include "tb/simulation.svh"
`include "common/common.svh"

module Pwm_tb;

	localparam DIV_BITS = `BYTE_BITS;
	localparam PERIOD_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire en;
	reg [PERIOD_BITS-1:0] period;
	reg [PERIOD_BITS-1:0] on_time;

	wire out;

	SimClock sim_clk (
		.out(clk)
	);

	FreqDivider #(
		.DIV_BITS(DIV_BITS)
	) freq_div (
		.clk(clk),
		.reset(reset),
		.en(1),
		.div(2),
		.out(en)
	);

	Pwm #(
		.PERIOD_BITS(PERIOD_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.en(en),
		.period(period),
		.on_time(on_time),
		.out(out)
	);

	initial begin
		reset = 1;
		period = 0;
		on_time = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		period = 3;
		#(`CLOCK_PERIOD * 10);

		on_time = 4;
		#(`CLOCK_PERIOD * 20);

		period = 5;
		#(`CLOCK_PERIOD * 100);

		on_time = 2;
		#(`CLOCK_PERIOD * 100);

		$stop;
	end // initial

endmodule : Pwm_tb
