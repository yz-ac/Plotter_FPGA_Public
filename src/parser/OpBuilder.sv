`include "common/common.svh"

import Op_PKG::Op_st;

/**
* Builds an opcode field by field.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input zero: Zeros all fields in the opcode.
* :input cmd: Value for the 'cmd' field.
* :input arg: Values for one of the 'arg' fields.
* :input flags: Value for the 'flags' field.
* :input set_cmd: Sets the 'cmd' field.
* :input set_arg_1: Sets the 'arg_1' field.
* :input set_arg_2: Sets the 'arg_2' field.
* :input set_arg_3: Sets the 'arg_3' field.
* :input set_arg_4: Sets the 'arg_4' field.
* :input set_flags: Sets the 'flags' field.
* :output op: The opcode being built.
*/
module OpBuilder (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic zero,
	input logic [`OP_CMD_BITS-1:0] cmd,
	input logic [`OP_ARG_BITS-1:0] arg,
	input logic [`OP_FLAGS_BITS-1:0] flags,
	input logic set_cmd,
	input logic set_arg_1,
	input logic set_arg_2,
	input logic set_arg_3,
	input logic set_arg_4,
	input logic set_flags,

	output Op_st op
);

	Op_st _op;

	assign op = _op;

	always_ff @(posedge clk) begin
		if (reset) begin
			_op.cmd <= 0;
			_op.arg_1 <= 0;
			_op.arg_2 <= 0;
			_op.arg_3 <= 0;
			_op.arg_4 <= 0;
			_op.flags <= 0;
		end
		else if (clk_en) begin
			_op.cmd <= _op.cmd;
			_op.arg_1 <= _op.arg_1;
			_op.arg_2 <= _op.arg_2;
			_op.arg_3 <= _op.arg_3;
			_op.arg_4 <= _op.arg_4;
			_op.flags <= _op.flags;

			if (set_cmd) begin
				_op.cmd <= cmd;
			end
			if (set_arg_1) begin
				_op.arg_1 <= arg;
			end
			if (set_arg_2) begin
				_op.arg_2 <= arg;
			end
			if (set_arg_3) begin
				_op.arg_3 <= arg;
			end
			if (set_arg_4) begin
				_op.arg_4 <= arg;
			end
			if (set_flags) begin
				_op.flags <= flags;
			end

			if (zero) begin
				_op.cmd <= 0;
				_op.arg_1 <= 0;
				_op.arg_2 <= 0;
				_op.arg_3 <= 0;
				_op.arg_4 <= 0;
				_op.flags <= 0;
			end
		end
		else begin
			_op.cmd <= _op.cmd;
			_op.arg_1 <= _op.arg_1;
			_op.arg_2 <= _op.arg_2;
			_op.arg_3 <= _op.arg_3;
			_op.arg_4 <= _op.arg_4;
			_op.flags <= _op.flags;
		end
	end // always_ff

endmodule : OpBuilder
