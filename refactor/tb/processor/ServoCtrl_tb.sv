`include "tb/simulation.svh"
`include "processor/processor.svh"

import Servo_P::ServoPos_t;

module ServoCtrl_tb;

	localparam DIV_BITS = 2;

	wire clk;
	reg reset;
	wire clk_en;
	ServoCtrl_IF intf();
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
		.div(1),
		.out(clk_en)
	);

	ServoCtrl UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(intf.slave),
		.out(out)
	);

	initial begin
		reset = 1;
		intf.master.trigger = 0;
		intf.master.pos = Servo_P::SERVO_POS_UP;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);
		// wait(intf.master.done == 0);

		intf.master.trigger = 0;
		// wait(intf.master.done == 1);
		#(`CLOCK_PERIOD * `SERVO_MOV_TIME * 2);

		intf.master.trigger = 1;
		intf.master.pos = Servo_P::SERVO_POS_DOWN;
		#(`CLOCK_PERIOD * 2);
		// wait(intf.master.done == 0);

		intf.master.trigger = 0;
		// wait(intf.master.done == 1);
		#(`CLOCK_PERIOD * `SERVO_MOV_TIME * 2);

		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);
		// wait(intf.master.done == 0);

		intf.master.trigger = 0;
		// wait(intf.master.done == 1);
		#(`CLOCK_PERIOD * `SERVO_MOV_TIME * 2);

		intf.master.trigger = 1;
		intf.master.pos = Servo_P::SERVO_POS_UP;
		#(`CLOCK_PERIOD * 2);
		// wait(intf.master.done == 0);

		intf.master.trigger = 0;
		// wait(intf.master.done == 1);
		#(`CLOCK_PERIOD * `SERVO_MOV_TIME * 2);

		$stop;
	end // initial

endmodule : ServoCtrl_tb
