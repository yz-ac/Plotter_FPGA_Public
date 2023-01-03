import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_M05;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

/**
* Chooses the outputs from the correct opcode handler.
*
* :input op: The current opcode being processed.
* :iface lin_motors_intf_in: Motors interface from linear handler.
* :iface circ_motors_intf_in: Motors interface from circular handler.
* :iface dummy_motors_intf_in: Motors interface from dummy handler.
* :iface lin_pos_update_intf_in: Position update interface from linear handler.
* :iface circ_pos_update_intf_in: Position update interface from circular handler.
* :iface dummy_pos_update_intf_in: Position update interface from dummy handler.
* :iface motors_intf_out: Chosen motors interface.
* :iface pos_update_intf_out: Chosen position update interface.
*/
module OpHandlerOutputChooser (
	input Op_st op,

	MotorsCtrl_IF lin_motors_intf_in,
	MotorsCtrl_IF circ_motors_intf_in,
	MotorsCtrl_IF dummy_motors_intf_in,

	PositionUpdate_IF lin_pos_update_intf_in,
	PositionUpdate_IF circ_pos_update_intf_in,
	PositionUpdate_IF dummy_pos_update_intf_in,

	MotorsCtrl_IF motors_intf_out,
	PositionUpdate_IF pos_update_intf_out
);

	// MACRO since SV doesn't allow interface assignment nor interfaces as
	// synthesizable function arguments
	`define CONNECT_MOTORS_INTERFACES(out, in) \
				out.pulse_num_x = in.pulse_num_x; \
				out.pulse_num_y = in.pulse_num_y; \
				out.servo_pos = in.servo_pos; \
				out.trigger = in.trigger; \
				in.done = out.done; \
				in.rdy = out.rdy

	`define CONNECT_POS_UPDATE_INTERFACES(out, in) \
				out.new_x = in.new_x; \
				out.new_y = in.new_y; \
				out.update = in.update

	`define ZERO_MOTORS_RETURN_SIGNALS(intf) \
				intf.done = 0; \
				intf.rdy = 0

	always_comb begin
		case (op.cmd)
		OP_CMD_G00: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(circ_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(dummy_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, lin_pos_update_intf_in);
		end
		OP_CMD_G01: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(circ_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(dummy_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, lin_pos_update_intf_in);
		end
		OP_CMD_G02: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, circ_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(dummy_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, circ_pos_update_intf_in);
		end
		OP_CMD_G03: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, circ_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(dummy_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, circ_pos_update_intf_in);
		end
		OP_CMD_M05: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, dummy_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(circ_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, dummy_pos_update_intf_in);
		end
		OP_CMD_G90: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, dummy_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(circ_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, dummy_pos_update_intf_in);
		end
		OP_CMD_G91: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, dummy_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(circ_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, dummy_pos_update_intf_in);
		end
		default: begin
			`CONNECT_MOTORS_INTERFACES(motors_intf_out, dummy_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(lin_motors_intf_in);
			`ZERO_MOTORS_RETURN_SIGNALS(circ_motors_intf_in);
			`CONNECT_POS_UPDATE_INTERFACES(pos_update_intf_out, dummy_pos_update_intf_in);
		end
		endcase
	end // always_comb

	`undef CONNECT_MOTORS_INTERFACES
	`undef CONNECT_POS_UPDATE_INTERFACES
	`undef ZERO_MOTORS_RETURN_SIGNALS

endmodule : OpHandlerOutputChooser
