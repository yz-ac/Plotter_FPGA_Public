`include "common/common.svh"

import Op_PKG::Op_st;

/**
* Dummy subparser - handles commands without arguments.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input cmd: The 'cmd' field of the parsed opcode.
* :iface sub_intf: Subparser interface.
* :iface pos_intf: Current position interface.
* :iface update_intf: Update current position interface.
* :output op: the parsed opcode.
*/
module DummySubparser (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic [`OP_CMD_BITS-1:0] cmd,
	Subparser_IF sub_intf,
	PositionUpdate_IF update_intf,
	output Op_st op
);

	reg _success;
	wire _set_success;
	wire _set_cmd;
	wire _zero;

	OpBuilder _op_builder (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.zero(_zero),
		.cmd(cmd),
		.arg(0),
		.flags(0),
		.set_cmd(_set_cmd),
		.set_arg_1(0),
		.set_arg_2(0),
		.set_arg_3(0),
		.set_arg_4(0),
		.set_flags(0),
		.op(op)
	);

	DummySubparser_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(sub_intf.trigger),
		.zero(_zero),
		.set_cmd(_set_cmd),
		.set_success(_set_success),
		.done(sub_intf.done),
		.rdy(sub_intf.rdy)
	);

	assign sub_intf.rd_trigger = 0;
	assign sub_intf.success = _success;
	assign sub_intf.newline = 0;

	assign update_intf.new_x = 0;
	assign update_intf.new_y = 0;
	assign update_intf.update = 0;

	always_ff @(posedge clk) begin
		if (reset) begin
			_success <= 0;
		end
		else if (clk_en) begin
			_success <= _success;

			if (_set_success) begin
				_success <= 1;
			end

			if (_zero) begin
				_success <= 0;
			end
		end
		else begin
			_success <= _success;
		end
	end // always_ff

endmodule : DummySubparser
