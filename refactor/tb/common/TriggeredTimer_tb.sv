`include "tb/simulation.svh"
`include "common/common.svh"

module TriggeredTimer_tb;
	int fd;

	localparam DIV_BITS = `BYTE_BITS;
	localparam TIMER_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire clk_en;
	reg en;
	reg [TIMER_BITS-1:0] count;
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
		.TIMER_BITS(TIMER_BITS)
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

	always_ff @(posedge done) begin
		`FWRITE(("time: %t, count: %d", $time, count))
	end

	initial begin
		`FOPEN("tests/tests/TriggeredTimer_tb.txt")

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

		`FCLOSE
		`STOP
	end // intial

endmodule : TriggeredTimer_tb
