`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

`define LOG() \
		`FWRITE(("time: %t, cmd: %d, new_x: %d, new_y: %d, op.cmd: %d", $time, cmd, update_intf.slave.new_x, update_intf.slave.new_x, op.cmd))

module SubparserOutputChooser_tb;
	int fd;

	reg [`OP_CMD_BITS-1:0] cmd;

	Op_st lin_op;
	Op_st circ_op;
	Op_st dummy_op;
	Op_st op;

	PositionUpdate_IF lin_update_intf ();
	PositionUpdate_IF circ_update_intf ();
	PositionUpdate_IF dummy_update_intf ();
	PositionUpdate_IF update_intf ();

	SubparserOutputChooser UUT (
		.cmd(cmd),
		.lin_op_in(lin_op),
		.circ_op_in(circ_op),
		.dummy_op_in(dummy_op),
		.lin_update_intf_in(lin_update_intf.slave),
		.circ_update_intf_in(circ_update_intf.slave),
		.dummy_update_intf_in(dummy_update_intf.slave),
		.op_out(op),
		.update_intf_out(update_intf.master)
	);

	initial begin
		`FOPEN("tests/tests/SubparserOutputChooser_tb.txt")

		lin_op = {OP_CMD_G00, 1, 1, 0, 0, 0};
		lin_update_intf.master.new_x = 1;
		lin_update_intf.master.new_y = 1;
		lin_update_intf.master.update = 1;

		circ_op = {OP_CMD_G02, 2, 2, 2, 2, 0};
		circ_update_intf.master.new_x = 2;
		circ_update_intf.master.new_y = 2;
		circ_update_intf.master.update = 0;

		dummy_op = {OP_CMD_G90, 0, 0, 0, 0, 0};
		dummy_update_intf.master.new_x = 3;
		dummy_update_intf.master.new_y = 3;
		dummy_update_intf.master.update = 1;

		cmd = OP_CMD_G00;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cmd = OP_CMD_G02;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cmd = OP_CMD_G90;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cmd = OP_CMD_G01;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cmd = OP_CMD_G03;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cmd = OP_CMD_G91;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : SubparserOutputChooser_tb
