`include "tb/simulation.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

`define LOG() \
		`FWRITE(("time: %t, cmd: %d, lin: %d, circ: %d, dummy: %d", $time, op.cmd, lin_handler_intf.slave.trigger, circ_handler_intf.slave.trigger, dummy_handler_intf.slave.trigger))

module OpHandlerInputChooser_tb;
	int fd;

	OpHandler_IF handler_intf ();
	OpHandler_IF lin_handler_intf ();
	OpHandler_IF circ_handler_intf ();
	OpHandler_IF dummy_handler_intf ();

	Op_st op;

	OpHandlerInputChooser UUT (
		.op(op),
		.handler_intf_in(handler_intf.slave),
		.lin_handler_intf_out(lin_handler_intf.master),
		.circ_handler_intf_out(circ_handler_intf.master),
		.dummy_handler_intf_out(dummy_handler_intf.master)
	);

	initial begin
		`FOPEN("tests/tests/OpHandlerInputChooser_tb.txt")

		handler_intf.master.trigger = 1;
		op = {OP_CMD_G00, 0, 0, 0, 0, 0};
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G02;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G90;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G01;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G03;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G91;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : OpHandlerInputChooser_tb
