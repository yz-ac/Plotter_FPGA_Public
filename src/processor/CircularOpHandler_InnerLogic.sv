`include "common/common.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;

import Position_PKG::PosDirection_t;
import Position_PKG::POS_DIR_UP;
import Position_PKG::POS_DIR_DOWN;
import Position_PKG::POS_DIR_LEFT;
import Position_PKG::POS_DIR_RIGHT;

/**
* Inner connections and logic of CircularOpHandler module.
*
* :param NUM_BITS: Field width of numbers for calculation.
* :param PULSE_NUM_X_BITS: Field width of X pulse number to motors.
* :param PULSE_NUM_Y_BITS: Field width of Y pulse number to motors.
* :param POS_X_BITS: Field width of X position coordinate.
* :param POS_Y_BITS: Field width of Y position coordinate.
* :input op: Opcode currently being processed.
* :iface state_intf: Interface for acquiring current position.
* :input last_x: X position when module was triggered.
* :input last_y: Y position when module was triggered.
* :input dir: Direction of next movement.
* :input is_last_mvt: Is the last movement in the circular motion.
* :output pulse_num_x: Number of pulses in X for motors.
* :output pulse_num_x: Number of pulses in Y for motors.
* :output new_x: New X coordinate after step.
* :output new_y: New Y coordinate after step.
* :output is_cw: Is clockwise movement.
* :output start_x: Starting X position relative to circle center.
* :output start_y: Starting Y position relative to circle center.
* :output cur_x: Current X position relative to circle center.
* :output cur_y: Current Y position relative to circle center.
* :output end_x: Final X position relative to circle center.
* :output end_y: Final Y position relative to circle center.
* :output r_squared: Squared radius of circular motion.
* :output cur_r_squared: Squared radius of current position (polar cooridnates).
* :output precise_crossing_axes: Is crossing axes in path calculated using precise (non integer) values.
* :output is_full_circle: Does command request drawing a full circle (in precise version).
*/
module CircularOpHandler_InnerLogic #(
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
	output logic is_cw,
	output logic [NUM_BITS-1:0] start_x,
	output logic [NUM_BITS-1:0] start_y,
	output logic [NUM_BITS-1:0] cur_x,
	output logic [NUM_BITS-1:0] cur_y,
	output logic [NUM_BITS-1:0] end_x,
	output logic [NUM_BITS-1:0] end_y,
	output logic [NUM_BITS-1:0] r_squared,
	output logic [NUM_BITS-1:0] cur_r_squared,
	output logic precise_crossing_axes,
	output logic is_full_circle
);

	// Wires
	wire [NUM_BITS-1:0] _x;
	wire [NUM_BITS-1:0] _y;
	wire [NUM_BITS-1:0] _i;
	wire [NUM_BITS-1:0] _j;

	// Internal signals are absolute, external are relative to circle center
	wire [NUM_BITS-1:0] _start_x;
	wire [NUM_BITS-1:0] _start_y;
	wire [NUM_BITS-1:0] _cur_x;
	wire [NUM_BITS-1:0] _cur_y;
	wire [NUM_BITS-1:0] _end_x;
	wire [NUM_BITS-1:0] _end_y;

	wire [NUM_BITS-1:0] _cur_rel_x;
	wire [NUM_BITS-1:0] _cur_rel_y;

	wire [NUM_BITS-1:0] _circ_center_x;
	wire [NUM_BITS-1:0] _circ_center_y;

	// Functions
	function automatic logic [NUM_BITS-1:0] square_num (
		input logic [NUM_BITS-1:0] num_in
	);
		
		// Assumes NUM_BITS is big enough for both input and output
		return num_in * num_in;

	endfunction : square_num

	// Logic
	assign _x = {{NUM_BITS-`OP_ARG_1_BITS{op.arg_1[`OP_ARG_1_BITS-1]}}, op.arg_1[`OP_ARG_1_BITS-1:0]};
	assign _y = {{NUM_BITS-`OP_ARG_2_BITS{op.arg_2[`OP_ARG_2_BITS-1]}}, op.arg_2[`OP_ARG_2_BITS-1:0]};
	assign _i = {{NUM_BITS-`OP_ARG_3_BITS{op.arg_3[`OP_ARG_3_BITS-1]}}, op.arg_3[`OP_ARG_3_BITS-1:0]};
	assign _j = {{NUM_BITS-`OP_ARG_4_BITS{op.arg_4[`OP_ARG_4_BITS-1]}}, op.arg_4[`OP_ARG_4_BITS-1:0]};
	assign r_squared = square_num(_i) + square_num(_j);
	assign is_cw = (op.cmd == OP_CMD_G02) ? 1 : 0;

	assign _start_x = {{NUM_BITS-state_intf.POS_X_BITS{last_x[state_intf.POS_X_BITS-1]}}, last_x[state_intf.POS_X_BITS-1:0]};
	assign _start_y = {{NUM_BITS-state_intf.POS_Y_BITS{last_y[state_intf.POS_Y_BITS-1]}}, last_y[state_intf.POS_Y_BITS-1:0]};
	assign _cur_x = {{NUM_BITS-state_intf.POS_X_BITS{state_intf.cur_x[state_intf.POS_X_BITS-1]}}, state_intf.cur_x[state_intf.POS_X_BITS-1:0]};
	assign _cur_y = {{NUM_BITS-state_intf.POS_Y_BITS{state_intf.cur_y[state_intf.POS_Y_BITS-1]}}, state_intf.cur_y[state_intf.POS_Y_BITS-1:0]};
	assign _end_x = (state_intf.is_absolute) ? (_x) : (_start_x + _x);
	assign _end_y = (state_intf.is_absolute) ? (_y) : (_start_y + _y);

	// Circle center is ALWAYS relative
	assign _circ_center_x = _start_x + _i;
	assign _circ_center_y = _start_y + _j;

	assign start_x = _start_x - _circ_center_x;
	assign start_y = _start_y - _circ_center_y;
	assign _cur_rel_x = _cur_x - _circ_center_x;
	assign _cur_rel_y = _cur_y - _circ_center_y;
	assign cur_x = _cur_rel_x;
	assign cur_y = _cur_rel_y;
	assign end_x = _end_x - _circ_center_x;
	assign end_y = _end_y - _circ_center_y;

	assign cur_r_squared = square_num(_cur_rel_x) + square_num(_cur_rel_y);

	assign precise_crossing_axes = op.flags[`OP_FLAGS_AXES_CROSS_BIT];
	assign is_full_circle = op.flags[`OP_FLAGS_FULL_CIRCLE_BIT];

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

endmodule : CircularOpHandler_InnerLogic
