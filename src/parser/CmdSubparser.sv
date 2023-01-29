`include "common/common.svh"

import Char_PKG::Char_t;

/**
* Subparser for parsing command literal in a Gcode line.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :iface sub_intf: Interface for controlling subparsers.
* :input char_in: Next character to parse.
* :output cmd: Parsed command code.
*/
module CmdSubparser (
	input logic clk,
	input logic reset,
	input logic clk_en,
	Subparser_IF sub_intf,
	input logic [`BYTE_BITS-1:0] char_in,

	output [`OP_CMD_BITS-1:0] cmd
);

	localparam CMD_BITS = `OP_CMD_BITS;

	Char_t _char_type;
	wire [`DIGIT_BITS-1:0] _digit;
	reg [`BYTE_BITS-1:0] _stored_char;

	reg _success;
	wire _zero;
	wire _store;
	wire _advance_num;
	wire _set_success;
	wire [CMD_BITS-1:0] _num;
	wire _is_valid;

	CharDecoder _char_decoder (
		.char_in(_stored_char),
		.char_type(_char_type)
	);

	AsciiToDigit _ascii_to_digit (
		.char_in(_stored_char),
		.digit_out(_digit)
	);

	NumberBuilder #(
		.NUM_BITS(CMD_BITS)
	) _number_builder (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.zero(_zero),
		.is_negative(0),
		.digit(_digit),
		.advance(_advance_num),
		.num(_num)
	);

	GcodeToCmd #(
		.NUM_BITS(CMD_BITS)
	) _gcode_to_cmd (
		.gcode(_num),
		.cmd(cmd),
		.is_valid(_is_valid)
	);

	CmdSubparser_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(sub_intf.trigger),
		.char_type(_char_type),
		.rd_done(sub_intf.rd_done),
		.rd_rdy(sub_intf.rd_rdy),
		.is_valid(_is_valid),
		.is_empty(sub_intf.is_empty),
		.done(sub_intf.done),
		.rdy(sub_intf.rdy),
		.rd_trigger(sub_intf.rd_trigger),
		.set_success(_set_success),
		.advance_num(_advance_num),
		.zero(_zero),
		.store(_store)
	);

	assign sub_intf.success = _success;

	always_ff @(posedge clk) begin
		if (reset) begin
			_success <= 0;
			_stored_char <= char_in;
		end
		else if (clk_en) begin
			_stored_char <= _stored_char;
			if (_store) begin
				_stored_char <= char_in;
			end

			if (_set_success) begin
				_success <= 1;
			end

			if (_zero) begin
				_success <= 0;
			end
		end
		else begin
			_success <= _success;
			_stored_char <= _stored_char;
		end
	end // always_ff

endmodule : CmdSubparser
