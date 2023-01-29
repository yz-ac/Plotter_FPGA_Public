`include "common/common.svh"

import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

/**
* Translates GCode number to opcode cmd.
*
* :param NUM_BITS: Width of gcode number field.
* :input gcode: The GCode number to translate.
* :output cmd: Opcode command field.
*/
module GcodeToCmd #(
	parameter NUM_BITS = `BYTE_BITS
)
(
	input logic [NUM_BITS-1:0] gcode,
	output logic [`OP_CMD_BITS-1:0] cmd,
	output logic is_valid
);

	always_comb begin
		case (gcode)
		0: begin
			cmd = OP_CMD_G00;
			is_valid = 1;
		end
		1: begin
			cmd = OP_CMD_G01;
			is_valid = 1;
		end
		2: begin
			cmd = OP_CMD_G02;
			is_valid = 1;
		end
		3: begin
			cmd = OP_CMD_G03;
			is_valid = 1;
		end
		90: begin
			cmd = OP_CMD_G90;
			is_valid = 1;
		end
		91: begin
			cmd = OP_CMD_G91;
			is_valid = 1;
		end
		default: begin
			cmd = OP_CMD_G00;
			is_valid = 0;
		end
		endcase
	end // always_comb

endmodule : GcodeToCmd
