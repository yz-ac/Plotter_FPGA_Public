`include "tb/simulation.svh"

import Op_PKG::Op_st;

module DummyOpHandler_tb;

	wire clk;
	reg reset;
	OpHandler_IF handler_intf ();
	MotorsCtrl_IF motors_intf ();

	wire done;
	wire rdy;

	Op_st op;

	SimClock sim_clk (
		.out(clk)
	);

	DummyOpHandler UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.handler_intf(handler_intf.slave),
		.motors_intf(motors_intf.master)
	);

	assign done = handler_intf.master.done;
	assign rdy = handler_intf.master.rdy;

	initial begin
		reset = 1;
		handler_intf.master.trigger = 0;
		op = {0, 0, 0, 0, 0, 0};
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		handler_intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		handler_intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 10);

		$stop;
	end // initial

endmodule : DummyOpHandler_tb
