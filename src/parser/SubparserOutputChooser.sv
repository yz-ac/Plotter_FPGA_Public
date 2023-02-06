`include "common/common.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

/**
* Chooses the outputs from the correct subparser.
*
* :input cmd: The 'cmd' field of the current Gcode command.
* :input lin_op_in: Opcode from the linear subparser.
* :input circ_op_in: Opcode from the circular subparser.
* :input dummy_op_in: Opcode from the dummy subparser.
* :iface lin_update_intf_in: Position update interface from linear subparser.
* :iface circ_update_intf_in: Position update interface from circular subparser.
* :iface dummy_update_intf_in: Position update interface from dummy subparser.
* :output op_out: Chosen opcode to pass.
* :iface update_intf_out: Chosen position update interface to pass.
*/
module SubparserOutputChooser (
	input logic [`OP_CMD_BITS-1:0] cmd,

	input Op_st lin_op_in,
	input Op_st circ_op_in,
	input Op_st dummy_op_in,

	PositionUpdate_IF lin_update_intf_in,
	PositionUpdate_IF circ_update_intf_in,
	PositionUpdate_IF dummy_update_intf_in,

	output Op_st op_out,
	PositionUpdate_IF update_intf_out
);

	// MACRO since SV doesn't allow interface assignment nor interfaces as
	// synthesizable function arguments
	`define CONNECT_POS_UPDATE_INTERFACES(out, in) \
				out.new_x = in.new_x; \
				out.new_y = in.new_y; \
				out.update = in.update

	always_comb begin
		case (cmd)
		OP_CMD_G00: begin
			op_out = lin_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, lin_update_intf_in);
		end
		OP_CMD_G01: begin
			op_out = lin_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, lin_update_intf_in);
		end
		OP_CMD_G02: begin
			op_out = circ_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, circ_update_intf_in);
		end
		OP_CMD_G03: begin
			op_out = circ_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, circ_update_intf_in);
		end
		OP_CMD_G90: begin
			op_out = dummy_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, dummy_update_intf_in);
		end
		OP_CMD_G91: begin
			op_out = dummy_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, dummy_update_intf_in);
		end
		default: begin
			op_out = dummy_op_in;
			`CONNECT_POS_UPDATE_INTERFACES(update_intf_out, dummy_update_intf_in);
		end
		endcase
	end // always_comb

	`undef CONNECT_POS_UPDATE_INTERFACES

endmodule : SubparserOutputChooser
