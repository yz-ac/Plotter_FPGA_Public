import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

/**
* Module to keep track of position and absolute / relative mode.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input op: Current processed opcode.
* :iface update_intf: Interface for updating position.
* :output cur_x: Current X position.
* :output cur_y: Current Y position.
* :output is_absolute: Is in absolute position mode.
*/
module PositionKeeper (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input Op_st op,
	PositionUpdate_IF update_intf,
	PositionState_IF state_intf
);

	reg [state_intf.POS_X_BITS-1:0] _cur_x;
	reg [state_intf.POS_Y_BITS-1:0] _cur_y;
	reg _is_absolute;

	assign state_intf.cur_x = _cur_x;
	assign state_intf.cur_y = _cur_y;
	assign state_intf.is_absolute = _is_absolute;

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_x <= 0;
			_cur_y <= 0;
			_is_absolute <= 1;
		end
		else if (clk_en) begin
			_cur_x <= _cur_x;
			_cur_y <= _cur_y;
			_is_absolute <= _is_absolute;
			if (op.cmd == OP_CMD_G90) begin
				_is_absolute <= 1;
			end
			else if (op.cmd == OP_CMD_G91) begin
				_is_absolute <= 0;
			end

			if (update_intf.update) begin
				_cur_x <= update_intf.new_x;
				_cur_y <= update_intf.new_y;
			end
		end
		else begin
			_cur_x <= _cur_x;
			_cur_y <= _cur_y;
			_is_absolute <= _is_absolute;
		end
	end

endmodule : PositionKeeper
