`include "common/common.svh"

import Op_PKG::Op_st;

import Position_PKG::PosDirection_t;
import Position_PKG::POS_DIR_UP;
import Position_PKG::POS_DIR_DOWN;
import Position_PKG::POS_DIR_LEFT;
import Position_PKG::POS_DIR_RIGHT;

/**
* Inner connections and logic of LinearOpHandler module.
*
* :param NUM_BITS: Field width of numbers for calculations.
* :param PULSE_NUM_X_BITS: Field width of X pulse number to motors.
* :param PULSE_NUM_Y_BITS: Field width of Y pulse number to motors.
* :param POS_X_BITS: Field width of X position coordinate.
* :param POS_Y_BITS: Field width of Y position coordinate.
* :input op: Opcode currently being processed.
* :iface state_intf: Interface for acquiring current position.
* :input last_x: X position when module was triggered.
* :input last_y: Y position when module was triggered.
* :input dir: Direction of next movement.
* :input is_last_mvt: Is the last movement in the linear motion.
* :output pulse_num_x: Number of pulses in X for motors.
* :output pulse_num_x: Number of pulses in Y for motors.
* :output new_x: New X coordinate after step.
* :output new_y: New Y coordinate after step.
* :output start_x: Starting X position.
* :output start_y: Starting Y position.
* :output cur_x: Current X position.
* :output cur_y: Current Y position.
* :output end_x: Final X position.
* :output end_y: Final Y position.
*/
module LinearOpHandler_InnerLogic #(
	parameter NUM_BITS = `BYTE_BITS,
	parameter PULSE_NUM_X_BITS = `BYTE_BITS,
	parameter PULSE_NUM_Y_BITS = `BYTE_BITS,
	parameter POS_X_BITS = `BYTE_BITS,
	parameter POS_Y_BITS = `BYTE_BITS
)
(
	input Op_st op,
	PositionState_IF state_intf,
	input logic [state_intf.POS_X_BITS-1:0] last_x,
	input logic [state_intf.POS_Y_BITS-1:0] last_y,
	input PosDirection_t dir,
	input logic is_last_mvt,

	output logic [PULSE_NUM_X_BITS-1:0] pulse_num_x,
	output logic [PULSE_NUM_Y_BITS-1:0] pulse_num_y,
	output logic [POS_X_BITS-1:0] new_x,
	output logic [POS_Y_BITS-1:0] new_y,
	output logic [NUM_BITS-1:0] start_x,
	output logic [NUM_BITS-1:0] start_y,
	output logic [NUM_BITS-1:0] cur_x,
	output logic [NUM_BITS-1:0] cur_y,
	output logic [NUM_BITS-1:0] end_x,
	output logic [NUM_BITS-1:0] end_y
);

	wire [NUM_BITS-1:0] _x;
	wire [NUM_BITS-1:0] _y;

	wire [NUM_BITS-1:0] _start_x;
	wire [NUM_BITS-1:0] _start_y;
	wire [NUM_BITS-1:0] _cur_x;
	wire [NUM_BITS-1:0] _cur_y;
	wire [NUM_BITS-1:0] _end_x;
	wire [NUM_BITS-1:0] _end_y;

	assign _x = {{NUM_BITS-`OP_ARG_1_BITS{op.arg_1[`OP_ARG_1_BITS-1]}}, op.arg_1[`OP_ARG_1_BITS-1:0]};
	assign _y = {{NUM_BITS-`OP_ARG_2_BITS{op.arg_2[`OP_ARG_2_BITS-1]}}, op.arg_2[`OP_ARG_2_BITS-1:0]};

	assign _start_x = {{NUM_BITS-state_intf.POS_X_BITS{last_x[state_intf.POS_X_BITS-1]}}, last_x[state_intf.POS_X_BITS-1:0]};
	assign _start_y = {{NUM_BITS-state_intf.POS_Y_BITS{last_y[state_intf.POS_Y_BITS-1]}}, last_y[state_intf.POS_Y_BITS-1:0]};
	assign _cur_x = {{NUM_BITS-state_intf.POS_X_BITS{state_intf.cur_x[state_intf.POS_X_BITS-1]}}, state_intf.cur_x[state_intf.POS_X_BITS-1:0]};
	assign _cur_y = {{NUM_BITS-state_intf.POS_Y_BITS{state_intf.cur_y[state_intf.POS_Y_BITS-1]}}, state_intf.cur_y[state_intf.POS_Y_BITS-1:0]};
	assign _end_x = (state_intf.is_absolute) ? (_x) : (_start_x + _x);
	assign _end_y = (state_intf.is_absolute) ? (_y) : (_start_y + _y);

	assign start_x = _start_x;
	assign start_y = _start_y;
	assign cur_x = _cur_x;
	assign cur_y = _cur_y;
	assign end_x = _end_x;
	assign end_y = _end_y;

	always_comb begin : __set_motors_and_update_pos
		// note that signals are being truncated here (and it's OK)
		if (is_last_mvt) begin
			pulse_num_x = (_end_x - _cur_x);
			pulse_num_y = (_end_y - _cur_y);
			new_x = _end_x;
			new_y = _end_y;
		end
		else begin
			case (dir)
			POS_DIR_UP: begin
				pulse_num_x = 0;
				pulse_num_y = 1;
				new_x = _cur_x;
				new_y = (_cur_y + 1);
			end
			POS_DIR_DOWN: begin
				pulse_num_x = 0;
				pulse_num_y = -1;
				new_x = _cur_x;
				new_y = (_cur_y - 1);
			end
			POS_DIR_LEFT: begin
				pulse_num_x = -1;
				pulse_num_y = 0;
				new_x = (_cur_x - 1);
				new_y = _cur_y;
			end
			default: begin
				pulse_num_x = 1;
				pulse_num_y = 0;
				new_x = (_cur_x + 1);
				new_y = _cur_y;
			end
			endcase
		end
	end : __set_motors_and_update_pos

endmodule : LinearOpHandler_InnerLogic
