import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_M05;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

module OpHandlerOutputChooser (
	input Op_st op,
	MotorsCtrl_IF lin_intf_in,
	MotorsCtrl_IF circ_intf_in,
	MotorsCtrl_IF dummy_intf_in,

	MotorsCtrl_IF motors_intf_out
);

	// MACRO since SV doesn't allow interface assignment nor interfaces as
	// synthesizable function arguments
	`define CONNECT_INTERFACES(out, in) \
				out.pulse_num_x = in.pulse_num_x; \
				out.pulse_num_y = in.pulse_num_y; \
				out.servo_pos = in.servo_pos; \
				out.trigger = in.trigger; \
				in.done = out.done; \
				in.rdy = out.rdy

	always_comb begin
		case (op.cmd)
		OP_CMD_G00: begin
			`CONNECT_INTERFACES(motors_intf_out, lin_intf_in);
		end
		OP_CMD_G01: begin
			`CONNECT_INTERFACES(motors_intf_out, lin_intf_in);
		end
		OP_CMD_G02: begin
			`CONNECT_INTERFACES(motors_intf_out, circ_intf_in);
		end
		OP_CMD_G03: begin
			`CONNECT_INTERFACES(motors_intf_out, circ_intf_in);
		end
		OP_CMD_M05: begin
			`CONNECT_INTERFACES(motors_intf_out, dummy_intf_in);
		end
		OP_CMD_G90: begin
			`CONNECT_INTERFACES(motors_intf_out, dummy_intf_in);
		end
		OP_CMD_G91: begin
			`CONNECT_INTERFACES(motors_intf_out, dummy_intf_in);
		end
		default: begin
			`CONNECT_INTERFACES(motors_intf_out, dummy_intf_in);
		end
		endcase
	end // always_comb

	`undef CONNECT_INTERFACES

endmodule : OpHandlerOutputChooser
