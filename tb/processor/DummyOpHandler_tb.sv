`include "tb/simulation.svh"
`include "processor/processor.svh"

module DummyOpHandler_tb;
	int fd;

	wire clk;
	reg reset;
	OpHandler_IF handler_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) motors_intf ();
	PositionUpdate_IF pos_update_intf ();

	wire done;
	wire rdy;

	SimClock sim_clk (
		.out(clk)
	);

	DummyOpHandler UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.handler_intf(handler_intf.slave),
		.motors_intf(motors_intf.master),
		.pos_update_intf(pos_update_intf.slave)
	);

	assign done = handler_intf.master.done;
	assign rdy = handler_intf.master.rdy;

	always_ff @(posedge done) begin
		`FWRITE(("time: %t", $time))
	end

	initial begin
		`FOPEN("tests/tests/DummyOpHandler_tb.txt")

		reset = 1;
		handler_intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		handler_intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		handler_intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 10);

		`FCLOSE
		`STOP
	end // initial

endmodule : DummyOpHandler_tb
