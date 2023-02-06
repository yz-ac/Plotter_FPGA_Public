`include "common/common.svh"

import Op_PKG::Op_st;
import Char_PKG::Char_t;

/**
* Module for parsing linear Gcode commands.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input cmd: The 'cmd' field of the opcode.
* :input char_in: Next character to parse.
* :iface sub_intf: Subparser interface.
* :iface pos_intf: Current position interface.
* :iface update_intf: Interface for updating precise position.
* :output op: The resulting opcode.
*/
module LinearSubparser (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic [`OP_CMD_BITS-1:0] cmd,
	input logic [`BYTE_BITS-1:0] char_in,
	Subparser_IF sub_intf,
	PositionState_IF pos_intf,
	PositionUpdate_IF update_intf,
	output Op_st op
);

	localparam NUM_BITS = `OP_ARG_BITS;
	localparam PRECISE_NUM_BITS = update_intf.POS_X_BITS + update_intf.POS_Y_BITS - 1;

	reg [update_intf.POS_X_BITS-1:0] _precise_x;
	reg [update_intf.POS_Y_BITS-1:0] _precise_y;
	reg _success;
	reg _newline;

	wire [NUM_BITS-1:0] _num;
	wire [PRECISE_NUM_BITS-1:0] _precise_num;

	wire _zero;
	wire _set_cmd;
	Char_t _arg_title;
	wire _set_x;
	wire _set_y;
	wire _set_success;
	wire _set_newline;

	Subparser_IF _arg_parser_intf ();
	wire _arg_parser_trigger;
	wire _arg_parser_done;
	wire _arg_parser_rdy;
	wire _arg_parser_success;
	wire _arg_parser_newline;
	wire _arg_too_big;

	OpBuilder _op_builder (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.zero(_zero),
		.cmd(cmd),
		.arg(_num),
		.flags(0),
		.set_cmd(_set_cmd),
		.set_arg_1(_set_x),
		.set_arg_2(_set_y),
		.set_arg_3(0),
		.set_arg_4(0),
		.set_flags(0),
		.op(op)
	);

	ArgSubparser #(
		.NUM_BITS(NUM_BITS),
		.PRECISE_NUM_BITS(PRECISE_NUM_BITS)
	) _arg_subparser (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.sub_intf(_arg_parser_intf.slave),
		.char_in(char_in),
		.arg_title(_arg_title),
		.num(_num),
		.precise_num(_precise_num),
		.arg_too_big(_arg_too_big)
	);

	LinearSubparser_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(sub_intf.trigger),
		.arg_parser_done(_arg_parser_done),
		.arg_parser_rdy(_arg_parser_rdy),
		.arg_parser_success(_arg_parser_success),
		.arg_parser_newline(_arg_parser_newline),
		.arg_too_big(_arg_too_big),
		.zero(_zero),
		.set_cmd(_set_cmd),
		.arg_title(_arg_title),
		.arg_parser_trigger(_arg_parser_trigger),
		.set_x(_set_x),
		.set_y(_set_y),
		.update_pos(update_intf.update),
		.set_success(_set_success),
		.set_newline(_set_newline),
		.done(sub_intf.done),
		.rdy(sub_intf.rdy)
	);

	SubparserConnector _subparser_connector (
		.subparser_trigger(_arg_parser_trigger),
		.subparser_rd_done(sub_intf.rd_done),
		.subparser_rd_rdy(sub_intf.rd_rdy),
		.subparser_is_empty(sub_intf.is_empty),
		.sub_intf(_arg_parser_intf.master),
		.subparser_done(_arg_parser_done),
		.subparser_rdy(_arg_parser_rdy),
		.subparser_rd_trigger(sub_intf.rd_trigger),
		.subparser_success(_arg_parser_success),
		.subparser_newline(_arg_parser_newline)
	);

	assign update_intf.new_x = (pos_intf.is_absolute) ? (_precise_x) : (pos_intf.cur_x + _precise_x);
	assign update_intf.new_y = (pos_intf.is_absolute) ? (_precise_y) : (pos_intf.cur_y + _precise_y);
	assign sub_intf.success = _success;
	assign sub_intf.newline = _newline;

	always_ff @(posedge clk) begin
		if (reset) begin
			_precise_x <= 0;
			_precise_y <= 0;
			_success <= 0;
			_newline <= 0;
		end
		else if (clk_en) begin
			_precise_x <= _precise_x;
			_precise_y <= _precise_y;
			_success <= _success;
			_newline <= _newline;

			if (_set_x) begin
				_precise_x <= _precise_num[update_intf.POS_X_BITS-1:0];
			end
			if (_set_y) begin
				_precise_y <= _precise_num[update_intf.POS_Y_BITS-1:0];
			end
			if (_set_success) begin
				_success <= 1;
			end
			if (_set_newline) begin
				_newline <= 1;
			end

			if (_zero) begin
				_precise_x <= 0;
				_precise_y <= 0;
				_success <= 0;
				_newline <= 0;
			end
		end
		else begin
			_precise_x <= _precise_x;
			_precise_y <= _precise_y;
			_success <= _success;
			_newline <= _newline;
		end
	end // always_ff

endmodule : LinearSubparser
