`include "common/common.svh"

import Op_PKG::Op_st;
import Char_PKG::Char_t;

/**
* Top module of Gcode parser.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input rd_done: Done reading.
* :input rd_rdy: Reader ready to accept triggers.
* :input is_empty: Nothing left to read.
* :input char_in: Next character to parse.
* :input wr_done: Done writing.
* :input wr_rdy: Writer ready to accept triggers.
* :input is_full: Nowhere to write.
* :output rd_trigger: Read the next character.
* :output wr_trigger: Write parsed opcode.
* :output op: The resulting opcode.
*/
module ParserTop (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_done,
	input logic rd_rdy,
	input logic is_empty,
	input logic [`BYTE_BITS-1:0] char_in,
	input logic wr_done,
	input logic wr_rdy,
	input logic is_full,

	output logic rd_trigger,
	output logic wr_trigger,
	output Op_st op
);

	Char_t _char_type;
	reg [`BYTE_BITS-1:0] _stored_char;

	wire [`OP_CMD_BITS-1:0] _cmd;
	Op_st _lin_op;
	Op_st _circ_op;
	Op_st _dummy_op;
	Op_st _op;

	PositionState_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) _pos_intf ();

	PositionUpdate_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) _lin_update_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) _circ_update_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) _dummy_update_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) _update_intf ();

	Subparser_IF _cmd_sub_intf ();
	wire _cmd_parser_trigger;
	wire _cmd_parser_rd_done;
	wire _cmd_parser_rd_rdy;
	wire _cmd_parser_is_empty;
	wire _cmd_parser_done;
	wire _cmd_parser_rdy;
	wire _cmd_parser_rd_trigger;
	wire _cmd_parser_success;
	wire _cmd_parser_newline;

	Subparser_IF _lin_arg_sub_intf ();
	Subparser_IF _circ_arg_sub_intf ();
	Subparser_IF _dummy_arg_sub_intf ();
	Subparser_IF _arg_sub_intf ();
	wire _arg_parser_trigger;
	wire _arg_parser_rd_done;
	wire _arg_parser_rd_rdy;
	wire _arg_parser_is_empty;
	wire _arg_parser_done;
	wire _arg_parser_rdy;
	wire _arg_parser_rd_trigger;
	wire _arg_parser_success;
	wire _arg_parser_newline;

	wire _store;
	wire _rd_trigger;
	wire _rd_done;
	wire _rd_rdy;
	wire _is_empty;
	wire _connect_cmd;
	wire _connect_args;

	CharDecoder _char_decoder (
		.char_in(_stored_char),
		.char_type(_char_type)
	);

	PositionKeeper _pos_keeper (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.op(_op),
		.update_intf(_update_intf.slave),
		.state_intf(_pos_intf.master)
	);

	CmdSubparser _cmd_subparser (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.sub_intf(_cmd_sub_intf.slave),
		.char_in(char_in),
		.cmd(_cmd)
	);

	DummySubparser _dummy_subparser (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.cmd(_cmd),
		.sub_intf(_dummy_arg_sub_intf.slave),
		.update_intf(_dummy_update_intf.master),
		.op(_dummy_op)
	);

	LinearSubparser _linear_subparser (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.cmd(_cmd),
		.char_in(char_in),
		.sub_intf(_lin_arg_sub_intf.slave),
		.pos_intf(_pos_intf.slave),
		.update_intf(_lin_update_intf.master),
		.op(_lin_op)
	);

	CircularSubparser _circular_subparser (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.cmd(_cmd),
		.char_in(char_in),
		.sub_intf(_circ_arg_sub_intf.slave),
		.pos_intf(_pos_intf.slave),
		.update_intf(_circ_update_intf.master),
		.op(_circ_op)
	);

	SubparserInputChooser _input_chooser (
		.cmd(_cmd),
		.sub_intf_in(_arg_sub_intf.slave),
		.lin_sub_intf_out(_lin_arg_sub_intf.master),
		.circ_sub_intf_out(_circ_arg_sub_intf.master),
		.dummy_sub_intf_out(_dummy_arg_sub_intf.master)
	);

	SubparserOutputChooser _output_chooser (
		.cmd(_cmd),
		.lin_op_in(_lin_op),
		.circ_op_in(_circ_op),
		.dummy_op_in(_dummy_op),
		.lin_update_intf_in(_lin_update_intf.slave),
		.circ_update_intf_in(_circ_update_intf.slave),
		.dummy_update_intf_in(_dummy_update_intf.slave),
		.op_out(_op),
		.update_intf_out(_update_intf.master)
	);

	SubparserConnector _cmd_connector (
		.subparser_trigger(_cmd_parser_trigger),
		.subparser_rd_done(_cmd_parser_rd_done),
		.subparser_rd_rdy(_cmd_parser_rd_rdy),
		.subparser_is_empty(_cmd_parser_is_empty),
		.sub_intf(_cmd_sub_intf.master),
		.subparser_done(_cmd_parser_done),
		.subparser_rdy(_cmd_parser_rdy),
		.subparser_rd_trigger(_cmd_parser_rd_trigger),
		.subparser_success(_cmd_parser_success),
		.subparser_newline(_cmd_parser_newline)
	);

	SubparserConnector _arg_connector (
		.subparser_trigger(_arg_parser_trigger),
		.subparser_rd_done(_arg_parser_rd_done),
		.subparser_rd_rdy(_arg_parser_rd_rdy),
		.subparser_is_empty(_arg_parser_is_empty),
		.sub_intf(_arg_sub_intf.master),
		.subparser_done(_arg_parser_done),
		.subparser_rdy(_arg_parser_rdy),
		.subparser_rd_trigger(_arg_parser_rd_trigger),
		.subparser_success(_arg_parser_success),
		.subparser_newline(_arg_parser_newline)
	);

	ParserTop_InnerConnect _inner_connect (
		.connect_cmd(_connect_cmd),
		.connect_args(_connect_args),
		.rd_done(rd_done),
		.rd_rdy(rd_rdy),
		.is_empty(is_empty),
		.cmd_rd_trigger(_cmd_parser_rd_trigger),
		.args_rd_trigger(_arg_parser_rd_trigger),
		.main_rd_trigger(_rd_trigger),
		.rd_trigger(rd_trigger),
		.cmd_rd_done(_cmd_parser_rd_done),
		.cmd_rd_rdy(_cmd_parser_rd_rdy),
		.cmd_is_empty(_cmd_parser_is_empty),
		.args_rd_done(_arg_parser_rd_done),
		.args_rd_rdy(_arg_parser_rd_rdy),
		.args_is_empty(_arg_parser_is_empty),
		.main_rd_done(_rd_done),
		.main_rd_rdy(_rd_rdy),
		.main_is_empty(_is_empty)
	);

	ParserTop_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.rd_done(_rd_done),
		.rd_rdy(_rd_rdy),
		.is_empty(_is_empty),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy),
		.is_full(is_full),
		.cmd_parser_done(_cmd_parser_done),
		.cmd_parser_rdy(_cmd_parser_rdy),
		.cmd_parser_success(_cmd_parser_success),
		.cmd_parser_newline(_cmd_parser_newline),
		.arg_parser_done(_arg_parser_done),
		.arg_parser_rdy(_arg_parser_rdy),
		.arg_parser_success(_arg_parser_success),
		.arg_parser_newline(_arg_parser_newline),
		.char_type(_char_type),
		.store(_store),
		.rd_trigger(_rd_trigger),
		.wr_trigger(wr_trigger),
		.cmd_parser_trigger(_cmd_parser_trigger),
		.arg_parser_trigger(_arg_parser_trigger),
		.connect_cmd(_connect_cmd),
		.connect_args(_connect_args)
	);

	assign op = _op;

	always_ff @(posedge clk) begin
		if (reset) begin
			_stored_char <= char_in;
		end
		else if (clk_en) begin
			_stored_char <= _stored_char;

			if (_store) begin
				_stored_char <= char_in;
			end
		end
		else begin
			_stored_char <= _stored_char;
		end
	end // always_ff

endmodule : ParserTop
