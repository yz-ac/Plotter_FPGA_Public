`include "tb/simulation.svh"
`include "common/common.svh"

import Char_PKG::Char_t;
import Char_PKG::CHAR_X;

module ArgSubparser_tb;
	int fd;

	localparam NUM_BITS = `POS_X_BITS;
	localparam PRECISE_NUM_BITS = `PRECISE_POS_X_BITS;

	wire clk;
	reg reset;
	Subparser_IF sub_intf ();
	wire [`BYTE_BITS-1:0] char_in;
	Char_t arg_title;
	wire [NUM_BITS-1:0] num;
	wire [PRECISE_NUM_BITS-1:0] precise_num;
	wire arg_too_big;

	SimClock sim_clk (
		.out(clk)
	);

	// data = X123.45 X 123.45\nX123 X.123 X-12.34 X -12.34 Y 12.34 X 12.a3 X --12.34 X 8192.0\n
	FifoBuffer #(
		.ROWS(80),
		.COLS(`BYTE_BITS),
		.INIT_FILE("data/arg_subparser_tb.mem"),
		.PRELOADED_ROWS(80)
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

	ArgSubparser #(
		.NUM_BITS(NUM_BITS),
		.PRECISE_NUM_BITS(PRECISE_NUM_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.sub_intf(sub_intf.slave),
		.char_in(char_in),
		.arg_title(arg_title),
		.num(num),
		.precise_num(precise_num),
		.arg_too_big(arg_too_big)
	);

	always_ff @(negedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 0;
	end

	always_ff @(posedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 1;
	end

	always_ff @(posedge sub_intf.master.rd_trigger or posedge sub_intf.slave.rd_done or posedge sub_intf.master.done) begin
		`FWRITE(("time: %t, char_in: %d, num: %d, precise_num: %d, arg_too_big: %d, success: %d, is_newline: %d", $time, char_in, num, precise_num, arg_too_big, sub_intf.master.success, sub_intf.master.newline))
	end

	always_ff @(posedge sub_intf.master.done) begin
		if (sub_intf.slave.is_empty) begin
			`FCLOSE
			`STOP
		end
	end

	initial begin
		`FOPEN("tests/tests/ArgSubparser_tb.txt")

		sub_intf.master.trigger = 0;
		reset = 1;
		arg_title = CHAR_X;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		sub_intf.master.trigger = 1;
	end

endmodule : ArgSubparser_tb
