`include "tb/simulation.svh"
`include "common/common.svh"
`include "processor/processor.svh"

module StepperCtrlXY_tb;

	localparam DIV_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire clk_en;
	wire out_x;
	wire dir_x;
	wire out_y;
	wire dir_y;

	StepperCtrlXY_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS),
		.PULSE_WIDTH_BITS(`STEPPER_PULSE_WIDTH_BITS)
	) intf ();

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

	StepperCtrlXY UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(intf.slave),
		.out_x(out_x),
		.dir_x(dir_x),
		.out_y(out_y),
		.dir_y(dir_y)
	);

	initial begin
		reset = 1;
		intf.master.trigger = 0;
		intf.master.pulse_width = `STEPPER_PULSE_WIDTH;
		intf.master.pulse_num_x = 0;
		intf.master.pulse_num_y = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		intf.master.trigger = 1;
		wait(intf.master.done == 0);

		intf.master.trigger = 0;
		wait(intf.master.rdy == 1);

		intf.master.pulse_num_x = 3;
		intf.master.trigger = 1;
		wait(intf.master.done == 0);

		intf.master.trigger = 0;
		wait(intf.master.rdy == 1);

		intf.master.pulse_num_y = 2;
		intf.master.trigger = 1;
		wait(intf.master.done == 0);

		intf.master.trigger = 0;
		wait(intf.master.rdy == 1);

		intf.master.pulse_num_x = 0;
		intf.master.trigger = 1;
		wait(intf.master.done == 0);

		intf.master.trigger = 0;
		wait(intf.master.rdy == 1);

		$stop;
	end // initial

endmodule : StepperCtrlXY_tb
