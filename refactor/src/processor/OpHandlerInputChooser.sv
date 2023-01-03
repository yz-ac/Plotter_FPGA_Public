import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_M05;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

/**
* Chooses the opcode handler to pass the inputs to.
*
* :input op: Current opcode being processed.
* :iface handler_intf_in: Handler interface to pass to handlers.
* :iface lin_handler_intf_out: Interface leading to the linear opcode handler.
* :iface circ_handler_intf_out: Interface leading to the circular opcode handler.
* :iface dummy_handler_intf_out: Interface leading to the dummy opcode handler.
*/
module OpHandlerInputChooser (
	input Op_st op,

	OpHandler_IF handler_intf_in,

	OpHandler_IF lin_handler_intf_out,
	OpHandler_IF circ_handler_intf_out,
	OpHandler_IF dummy_handler_intf_out
);

	// MACRO since SV doesn't allow interface assignment nor interfaces as
	// synthesizable function arguments
	`define CONNECT_HANDLER_INTERFACES(out, in) \
				out.trigger = in.trigger; \
				in.done = out.done; \
				in.rdy = out.rdy

	`define ZERO_HANDLER_FORWARD_SIGNALS(intf) \
				intf.trigger = 0

	always_comb begin
		case (op.cmd)
			OP_CMD_G00: begin
				`CONNECT_HANDLER_INTERFACES(lin_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(circ_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(dummy_handler_intf_out);
			end
			OP_CMD_G01: begin
				`CONNECT_HANDLER_INTERFACES(lin_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(circ_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(dummy_handler_intf_out);
			end
			OP_CMD_G02: begin
				`CONNECT_HANDLER_INTERFACES(circ_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(lin_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(dummy_handler_intf_out);
			end
			OP_CMD_G03: begin
				`CONNECT_HANDLER_INTERFACES(circ_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(lin_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(dummy_handler_intf_out);
			end
			OP_CMD_M05: begin
				`CONNECT_HANDLER_INTERFACES(dummy_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(lin_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(circ_handler_intf_out);
			end
			OP_CMD_G90: begin
				`CONNECT_HANDLER_INTERFACES(dummy_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(lin_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(circ_handler_intf_out);
			end
			OP_CMD_G91: begin
				`CONNECT_HANDLER_INTERFACES(dummy_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(lin_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(circ_handler_intf_out);
			end
			default: begin
				`CONNECT_HANDLER_INTERFACES(dummy_handler_intf_out, handler_intf_in);
				`ZERO_HANDLER_FORWARD_SIGNALS(lin_handler_intf_out);
				`ZERO_HANDLER_FORWARD_SIGNALS(circ_handler_intf_out);
			end
		endcase
	end // always_comb

	`undef CONNECT_HANDLER_INTERFACES
	`undef ZERO_HANDLER_FORWARD_SIGNALS

endmodule : OpHandlerInputChooser
