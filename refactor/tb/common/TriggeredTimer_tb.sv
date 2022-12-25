`include "tb/simulation.svh"
`include "common/common.svh"

module TriggeredTimer_tb;

	localparam DIV_BITS = `BYTE_BITS;
	localparam COUNTER_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire clk_en;
	reg en;
	reg [COUNTER_BITS-1:0] count;
	reg trigger;
	wire done;
	wire rdy;

	SimClock sim_clk (
		.out(clk)
	);

	FreqDivider #(
		.DIV_BITS(DIV_BITS)
	) freq_div (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.en(1),
		.div(2),
		.out(clk_en)
	);

	TriggeredTimer #(
		.COUNTER_BITS(COUNTER_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.en(en),
		.count(count),
		.trigger(trigger),
		.done(done),
		.rdy(rdy)
	);

	initial begin
		reset = 1;
		en = 0;
		count = 3;
		trigger = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		en = 1;
		#(`CLOCK_PERIOD * 10);

		count = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		trigger = 1;
		count = 5;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 20);

		$stop;
	end // intial

endmodule : TriggeredTimer_tb
