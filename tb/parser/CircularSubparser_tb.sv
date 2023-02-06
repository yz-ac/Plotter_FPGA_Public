`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G03;

module CircularSubparser_tb;
	int fd;

	wire clk;
	reg reset;
	reg [`OP_CMD_BITS-1:0] cmd;
	wire [`BYTE_BITS-1:0] char_in;
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
		.update_intf(update_intf.slave),
		.state_intf(pos_intf.master)
	);

	// data = G03 X 0.0 Y 10.2 I 0.0 J 5.1\nG03 X 20000.0 Y 0.0 I 11.2 J 32.3\nG03 X10.2 Y0.0 I5.1 J0.0\nG03 X 7.5 Y 12.5 I -5.1 J 0.0\nG03 X 12.0 Y 10.0 I 8192.3 J 2.3\n
	FifoBuffer #(
		.ROWS(151),
		.COLS(`BYTE_BITS),
		.INIT_FILE("data/circular_subparser_tb.mem"),
		.PRELOADED_ROWS(151)
	) fifo_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(sub_intf.master.rd_trigger),
		.wr_trigger(0),
		.wr_data(0),
		.rd_data(char_in),
		.is_empty(sub_intf.master.is_empty),
		.is_full(),
		.rd_done(sub_intf.master.rd_done),
		.rd_rdy(sub_intf.master.rd_rdy),
		.wr_done(),
		.wr_rdy()
	);

	CircularSubparser UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.cmd(cmd),
		.char_in(char_in),
		.sub_intf(sub_intf.slave),
		.pos_intf(pos_intf.slave),
		.update_intf(update_intf.master),
		.op(op)
	);

	always_ff @(negedge reset) begin
		sub_intf.master.trigger <= 1;
	end

	always_ff @(negedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 0;
	end

	always_ff @(posedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 1;
	end

	always_ff @(posedge sub_intf.master.done) begin
		`FWRITE(("time: %t, cmd: %d, x: %d, y: %d, i: %d, j: %d, flags: %d, cur_x: %d, cur_y: %d, success: %d, newline: %d", $time, op.cmd, op.arg_1, op.arg_2, op.arg_3, op.arg_4, op.flags, pos_intf.slave.cur_x, pos_intf.slave.cur_y, sub_intf.master.success, sub_intf.master.newline))
	end

	always_ff @(posedge sub_intf.master.done) begin
		if (sub_intf.slave.is_empty) begin
			`FCLOSE
			`STOP
		end
	end

	initial begin
		`FOPEN("tests/tests/CircularSubparser_tb.txt")

		cmd = OP_CMD_G03;
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;

	end // initial

endmodule : CircularSubparser_tb
