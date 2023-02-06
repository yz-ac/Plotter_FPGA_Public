`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

`define LOG() \
		`FWRITE(("time: %t, cmd: %d, lin: %d, circ: %d, dummy: %d", $time, cmd, lin_sub_intf.slave.trigger, circ_sub_intf.slave.trigger, dummy_sub_intf.slave.trigger))

module SubparserInputChooser_tb;
	int fd;

	Subparser_IF sub_intf ();
	Subparser_IF lin_sub_intf ();
	Subparser_IF circ_sub_intf ();
	Subparser_IF dummy_sub_intf ();

	reg [`OP_CMD_BITS-1:0] cmd;

	SubparserInputChooser UUT (
		.cmd(cmd),
		.sub_intf_in(sub_intf.slave),
		.lin_sub_intf_out(lin_sub_intf.master),
		.circ_sub_intf_out(circ_sub_intf.master),
		.dummy_sub_intf_out(dummy_sub_intf.master)
	);

	initial begin
		`FOPEN("tests/tests/SubparserInputChooser_tb.txt")

		sub_intf.master.trigger = 1;
		sub_intf.master.rd_done = 1;
		sub_intf.master.rd_rdy = 1;
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

endmodule : SubparserInputChooser_tb
