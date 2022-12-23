`include "tb/simulation.svh"
`include "common/common.svh"

module StepperCtrl_tb;

	localparam DIV_BITS = `BYTE_BITS;
	localparam PULSE_NUM_BITS = `BYTE_BITS;
	localparam PULSE_WIDTH_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire en;

	wire out;
	wire dir;

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

	StepperCtrl_IF #(
		.PULSE_NUM_BITS(PULSE_NUM_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_BITS)
	) intf (
		.out(out),
		.dir(dir)
	);

	StepperCtrl UUT (
		.clk(clk),
		.reset(reset),
		.en(en),
		.intf(intf.slave)
	);

	initial begin
		reset = 1;
		intf.master.trigger = 0;
		intf.master.pulse_num = 0;
		intf.master.pulse_width = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 4);

		intf.master.pulse_num = -4;
		intf.master.pulse_width = 2;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 40);

		intf.master.pulse_num = 2;
		intf.master.pulse_width = 3;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 30);

		$stop;
	end // initial

endmodule : StepperCtrl_tb
