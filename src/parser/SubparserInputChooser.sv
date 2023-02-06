`include "common/common.svh"

import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

/**
* Chooses the subparser handler to pass the inputs to.
*
* :input cmd: The 'cmd' field of the command being processed.
* :iface sub_intf_in: Subparser interface to pass to the subparsers.
* :iface lin_sub_intf_out: Interface leading to the linear subparser.
* :iface circ_sub_intf_out: Interface leading to the circular subparser.
* :iface dummy_sub_intf_out: Interface leading to the dummy subparser.
*/
module SubparserInputChooser (
	input [`OP_CMD_BITS-1:0] cmd,

	Subparser_IF sub_intf_in,

	Subparser_IF lin_sub_intf_out,
	Subparser_IF circ_sub_intf_out,
	Subparser_IF dummy_sub_intf_out
);

	// MACRO since SV doesn't allow interface assignment nor interfaces as
	// synthesizable function arguments
	`define CONNECT_SUBPARSER_INTERFACES(out, in) \
				out.trigger = in.trigger; \
				in.done = out.done; \
				in.rdy = out.rdy; \
				in.rd_trigger = out.rd_trigger; \
				out.rd_done = in.rd_done; \
				out.rd_rdy = in.rd_rdy; \
				out.is_empty = in.is_empty; \
				in.success = out.success; \
				in.newline = out.newline

	`define ZERO_SUBPARSER_FORWARD_SIGNALS(intf) \
				intf.trigger = 0; \
				intf.rd_done = 0; \
				intf.is_empty = 0

	always_comb begin
		case (cmd)
			OP_CMD_G00: begin
				`CONNECT_SUBPARSER_INTERFACES(lin_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(circ_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(dummy_sub_intf_out);
			end
			OP_CMD_G01: begin
				`CONNECT_SUBPARSER_INTERFACES(lin_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(circ_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(dummy_sub_intf_out);
			end
			OP_CMD_G02: begin
				`CONNECT_SUBPARSER_INTERFACES(circ_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(lin_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(dummy_sub_intf_out);
			end
			OP_CMD_G03: begin
				`CONNECT_SUBPARSER_INTERFACES(circ_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(lin_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(dummy_sub_intf_out);
			end
			OP_CMD_G90: begin
				`CONNECT_SUBPARSER_INTERFACES(dummy_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(lin_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(circ_sub_intf_out);
			end
			OP_CMD_G91: begin
				`CONNECT_SUBPARSER_INTERFACES(dummy_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(lin_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(circ_sub_intf_out);
			end
			default: begin
				`CONNECT_SUBPARSER_INTERFACES(dummy_sub_intf_out, sub_intf_in);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(lin_sub_intf_out);
				`ZERO_SUBPARSER_FORWARD_SIGNALS(circ_sub_intf_out);
			end
		endcase
	end

	`undef CONNECT_SUBPARSER_INTERFACES
	`undef ZERO_SUBPARSER_FORWARD_SIGNALS

endmodule : SubparserInputChooser
