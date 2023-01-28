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
		`FWRITE(("time: %t, op.cmd: %d, op.arg_1: %d, op.arg_2: %d, op.arg_3: %d, op.arg_4: %d, op.flags: %d", $time, op.cmd, op.arg_1, op.arg_2, op.arg_3, op.arg_4, op.flags))

module OpBuilder_tb;
	int fd;

	wire clk;
	reg reset;
	reg zero;
	reg [`OP_CMD_BITS-1:0] cmd;
	reg [`OP_ARG_BITS-1:0] arg;
	reg [`OP_FLAGS_BITS-1:0] flags;
	reg set_cmd;
	reg set_arg_1;
	reg set_arg_2;
	reg set_arg_3;
	reg set_arg_4;
	reg set_flags;

	Op_st op;

	SimClock sim_clk (
		.out(clk)
	);

	OpBuilder UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.zero(zero),
		.cmd(cmd),
		.arg(arg),
		.flags(flags),
		.set_cmd(set_cmd),
		.set_arg_1(set_arg_1),
		.set_arg_2(set_arg_2),
		.set_arg_3(set_arg_3),
		.set_arg_4(set_arg_4),
		.set_flags(set_flags),
		.op(op)
	);

	initial begin
		`FOPEN("tests/tests/OpBuilder_tb.txt")

		reset = 1;
		zero = 0;
		cmd = OP_CMD_G00;
		arg = 0;
		flags = 0;
		set_cmd = 0;
		set_arg_1 = 0;
		set_arg_2 = 0;
		set_arg_3 = 0;
		set_arg_4 = 0;
		set_flags = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		reset = 0;
		cmd = OP_CMD_G03;
		arg = 1;
		set_cmd = 1;
		set_arg_1 = 1;
		#(`CLOCK_PERIOD);
		`LOG

		set_cmd = 0;
		set_arg_1 = 0;
		arg = 2;
		set_arg_2 = 1;
		#(`CLOCK_PERIOD);
		`LOG

		set_arg_2 = 0;
		arg = 3;
		set_arg_3 = 1;
		#(`CLOCK_PERIOD);
		`LOG

		set_arg_3 = 0;
		arg = 4;
		flags = 3;
		set_arg_4 = 1;
		set_flags = 1;
		#(`CLOCK_PERIOD);
		`LOG

		set_arg_4 = 0;
		set_flags = 0;
		zero = 1;
		#(`CLOCK_PERIOD);
		`LOG

		zero = 0;
		cmd = OP_CMD_G01;
		arg = 5;
		set_cmd = 1;
		set_arg_1 = 1;
		set_arg_2 = 1;
		#(`CLOCK_PERIOD);
		`LOG

		set_arg_1 = 0;
		set_arg_2 = 0;
		#(`CLOCK_PERIOD);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : OpBuilder_tb
