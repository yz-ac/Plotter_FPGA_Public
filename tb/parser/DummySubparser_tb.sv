`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

module DummySubparser_tb;
	int fd;

	wire clk;
	reg reset;
	reg [`OP_CMD_BITS-1:0] cmd;
	Subparser_IF sub_intf ();
	PositionState_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) pos_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) update_intf ();
	Op_st op;

	SimClock sim_clk (
		.out(clk)
	);

	PositionKeeper pos_keeper (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.update_intf(update_intf.master),
		.state_intf(pos_intf.master)
	);

	DummySubparser UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.cmd(cmd),
		.sub_intf(sub_intf.slave),
		.pos_intf(pos_intf.slave),
		.update_intf(update_intf.slave),
		.op(op)
	);

	typedef enum {
		TB_TEST_1,
		TB_TEST_2,
		TB_BAD
	} DummyParser_tb_test;

	DummyParser_tb_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		cmd <= OP_CMD_G91;
		sub_intf.master.trigger <= 1;
	end

	always_ff @(negedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 0;
	end

	always_ff @(posedge sub_intf.master.rdy) begin
		case (_test)
		TB_TEST_1: begin
			_test <= TB_TEST_2;
			cmd <= OP_CMD_G90;
			sub_intf.master.trigger <= 1;
		end
		TB_TEST_2: begin
			`FCLOSE
			`STOP
		end
		default: begin
			_test <= TB_BAD;
			sub_intf.master.trigger <= 0;
		end
		endcase
	end

	always_ff @(posedge sub_intf.master.done) begin
		`FWRITE(("time: %t, cmd: %d, arg_1: %d, arg_2: %d, arg_3: %d, arg_4: %d, flags: %d, is_absolute: %d", $time, op.cmd, op.arg_1, op.arg_2, op.arg_3, op.arg_4, op.flags, pos_intf.slave.is_absolute))
	end

	initial begin
		`FOPEN("tests/tests/DummySubparser_tb.txt")

		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		sub_intf.master.rd_done = 1;
		sub_intf.master.rd_rdy = 1;
		sub_intf.master.is_empty = 1;

	end // initial

endmodule : DummySubparser_tb
