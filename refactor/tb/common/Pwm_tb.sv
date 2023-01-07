`include "tb/simulation.svh"
`include "common/common.svh"

module Pwm_tb;
	int fd;

	localparam DIV_BITS = `BYTE_BITS;
	localparam PERIOD_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire clk_en;
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
		.clk_en(1),
		.en(1),
		.div(2),
		.out(clk_en)
	);

	Pwm #(
		.PERIOD_BITS(PERIOD_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.period(period),
		.on_time(on_time),
		.out(out)
	);

	always_ff @(posedge out) begin
		`FWRITE(("time: %t, period: %d, on_time: %d", $time, period, on_time))
	end

	initial begin
		`FOPEN("tests/tests/Pwm_tb.txt")

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

		`FCLOSE
		`STOP
	end // initial

endmodule : Pwm_tb
