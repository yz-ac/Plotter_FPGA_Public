`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::Op_st;

module ParserTop_tb;

	wire clk;
	reg reset;
	wire rd_done;
	wire rd_rdy;
	wire is_empty;
	wire [`BYTE_BITS-1:0] char_in;
	wire wr_done;
	wire wr_rdy;
	wire is_full;
	wire rd_trigger;
	wire wr_trigger;
	Op_st op;

	wire [`OP_BITS-1:0] op_out;

	SimClock sim_clk (
		.out(clk)
	);

	FifoBuffer #(
		.ROWS(19132),
		.COLS(`BYTE_BITS),
		.INIT_FILE("data/parser_top_tb.mem"),
		.PRELOADED_ROWS(19132)
	) rd_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(rd_trigger),
		.wr_trigger(0),
		.wr_data(0),
		.rd_data(char_in),
		.is_empty(is_empty),
		.is_full(),
		.rd_done(rd_done),
		.rd_rdy(rd_rdy),
		.wr_done(),
		.wr_rdy()
	);

	FifoBuffer #(
		.ROWS(315),
		.COLS(`OP_BITS)
	) wr_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(0),
		.wr_trigger(wr_trigger),
		.wr_data(op_out),
		.rd_data(),
		.is_empty(),
		.is_full(is_full),
		.rd_done(),
		.rd_rdy(),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy)
	);

	ParserTop UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_done(rd_done),
		.rd_rdy(rd_rdy),
		.is_empty(is_empty),
		.char_in(char_in),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy),
		.is_full(is_full),
		.rd_trigger(rd_trigger),
		.wr_trigger(wr_trigger),
		.op(op)
	);

	assign op_out[63:56] = op.cmd;
	assign op_out[55:44] = op.arg_1;
	assign op_out[43:32] = op.arg_2;
	assign op_out[31:20] = op.arg_3;
	assign op_out[19:8] = op.arg_4;
	assign op_out[7:0] = op.flags;

	always_ff @(posedge is_empty) begin
		$writememh("tests/tests/ParserTop_tb.txt", wr_buf._bram._mem);
		`STOP
	end

	initial begin
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : ParserTop_tb
