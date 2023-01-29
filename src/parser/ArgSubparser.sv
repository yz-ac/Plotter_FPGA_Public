`include "common/common.svh"

import Char_PKG::Char_t;

module ArgSubparser #(
	parameter NUM_BITS = `BYTE_BITS,
	parameter PRECISE_NUM_BITS = `WORD_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	Subparser_IF sub_intf,
	input logic [`BYTE_BITS-1:0] char_in,
	input Char_t arg_title,

	output logic [NUM_BITS-1:0] num,
	output logic [PRECISE_NUM_BITS-1:0] precise_num,
	output logic arg_too_big
);

	localparam WIDE_NUM_BITS = NUM_BITS * 2;

	Char_t _char_type;
	wire [`DIGIT_BITS-1:0] _digit;
	reg [`BYTE_BITS-1:0] _stored_char;

	reg _success;
	reg _arg_too_big;
	reg _is_negative;
	wire _zero;
	wire _store;
	wire _advance_num;
	wire _advance_precise_num;
	wire _set_success;
	wire _set_too_big;
	wire _set_negative;
	wire _is_valid;
	wire [WIDE_NUM_BITS-1:0] _num;
	wire [PRECISE_NUM_BITS-1:0] _precise_num;

	CharDecoder _char_decoder (
		.char_in(_stored_char),
		.char_type(_char_type)
	);

	AsciiToDigit _ascii_to_digit (
		.char_in(_stored_char),
		.digit_out(_digit)
	);

	NumberBuilder #(
		.NUM_BITS(WIDE_NUM_BITS)
	) _number_builder (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.zero(_zero),
		.is_negative(_is_negative),
		.digit(_digit),
		.advance(_advance_num),
		.num(_num)
	);

	NumberBuilder #(
		.NUM_BITS(PRECISE_NUM_BITS)
	) _precise_number_builder (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.zero(_zero),
		.is_negative(_is_negative),
		.digit(_digit),
		.advance(_advance_precise_num),
		.num(_precise_num)
	);

	ArgSizeCheck #(
		.MAX_ARG_BITS(NUM_BITS)
	) _arg_size_check (
		.num(_num),
		.is_valid(_is_valid)
	);

	ArgSubparser_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(sub_intf.trigger),
		.char_type(_char_type),
		.arg_title(arg_title),
		.rd_done(sub_intf.rd_done),
		.rd_rdy(sub_intf.rd_rdy),
		.is_empty(sub_intf.is_empty),
		.is_valid(_is_valid),
		.done(sub_intf.done),
		.rdy(sub_intf.rdy),
		.rd_trigger(sub_intf.rd_trigger),
		.set_success(_set_success),
		.set_too_big(_set_too_big),
		.advance_num(_advance_num),
		.advance_precise_num(_advance_precise_num),
		.set_negative(_set_negative),
		.zero(_zero),
		.store(_store)
	);

	assign num = _num[NUM_BITS-1:0];
	assign precise_num = _precise_num;
	assign arg_too_big = _arg_too_big;
	assign sub_intf.success = _success;

	always_ff @(posedge clk) begin
		if (reset) begin
			_success <= 0;
			_arg_too_big <= 0;
			_is_negative <= 0;
			_stored_char <= char_in;
		end
		else if (clk_en) begin
			_success <= _success;
			_arg_too_big <= _arg_too_big;
			_is_negative <= _is_negative;
			_stored_char <= _stored_char;

			if (_store) begin
				_stored_char <= char_in;
			end

			if (_set_success) begin
				_success <= 1;
			end
			if (_set_too_big) begin
				_arg_too_big <= 1;
			end
			if (_set_negative) begin
				_is_negative <= 1;
			end

			if (_zero) begin
				_success <= 0;
				_arg_too_big <= 0;
				_is_negative <= 0;
			end
		end
		else begin
			_success <= _success;
			_arg_too_big <= _arg_too_big;
			_is_negative <= _is_negative;
			_stored_char <= _stored_char;
		end
	end // always_ff

endmodule : ArgSubparser
