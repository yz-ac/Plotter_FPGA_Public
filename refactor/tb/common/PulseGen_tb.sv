`include "tb/simulation.svh"
`include "common/common.svh"

module PulseGen_tb;

	localparam DIV_BITS = `BYTE_BITS;
	localparam PULSE_NUM_BITS = `BYTE_BITS;
	localparam PULSE_WIDTH_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire en;
	reg [PULSE_NUM_BITS-1:0] pulse_num;
	reg [PULSE_WIDTH_BITS-1:0] pulse_width;
	reg trigger;

	wire out;
	wire done;

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

	PulseGen #(
		.PULSE_NUM_BITS(PULSE_NUM_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.en(en),
		.pulse_num(pulse_num),
		.pulse_width(pulse_width),
		.trigger(trigger),
		.out(out),
		.done(done)
	);

	initial begin
		reset = 1;
		pulse_num = 0;
		pulse_width = 0;
		trigger = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 4);

		pulse_num = 3;
		pulse_width = 2;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 40);

		pulse_num = 2;
		pulse_width = 5;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 40);

		$stop;
	end // initial

endmodule : PulseGen_tb
