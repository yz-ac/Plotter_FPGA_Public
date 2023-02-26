`include "common/common.svh"

import Op_PKG::Op_st;
import Position_PKG::PosQuadrant_t;
import Position_PKG::PosDirection_t;
import Servo_PKG::SERVO_POS_DOWN;

/**
* Handler for circular motion commands (G02, G03).
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input op: Opcode currently being processed.
* :iface handler_intf: Interface for opcode handlers.
* :iface state_intf: Interface to current position and mode (absolute / relative).
* :iface update_intf: Interface to update current position.
* :iface motors_intf: Interface to motor control.
*/
module CircularOpHandler (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input Op_st op,
	OpHandler_IF handler_intf,
	PositionState_IF state_intf,
	PositionUpdate_IF update_intf,
	MotorsCtrl_IF motors_intf
);

	// parameters
	localparam RADIUS_BITS = state_intf.POS_X_BITS + state_intf.POS_Y_BITS - 1;
	localparam NUM_BITS = 2 * RADIUS_BITS;
	localparam STEP_BITS = NUM_BITS + 3;

	// wires and registers
	wire _rdy;
	reg [state_intf.POS_X_BITS-1:0] _last_x;
	reg [state_intf.POS_Y_BITS-1:0] _last_y;

	wire _is_cw;
	wire [NUM_BITS-1:0] _start_x;
	wire [NUM_BITS-1:0] _start_y;
	wire [NUM_BITS-1:0] _cur_x;
	wire [NUM_BITS-1:0] _cur_y;
	wire [NUM_BITS-1:0] _end_x;
	wire [NUM_BITS-1:0] _end_y;

	wire [NUM_BITS-1:0] _r_squared;
	wire _sqrt_trigger;
	wire _sqrt_done;
	wire _sqrt_rdy;
	wire [NUM_BITS-1:0] _r;

	wire [NUM_BITS-1:0] _cur_r_squared;
	PosQuadrant_t _cur_quadrant;
	PosDirection_t _nxt_dir;

	wire _is_last_mvt;
	wire _update_counter;

	wire [STEP_BITS-1:0] _num_steps;
	reg [STEP_BITS-1:0] _steps_counter;
	wire _reached_num_steps;
	wire _precise_crossing_axes;
	wire _is_full_circle;

	// modules
	CircularOpHandler_InnerLogic #(
		.NUM_BITS(NUM_BITS),
		.PULSE_NUM_X_BITS(motors_intf.PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(motors_intf.PULSE_NUM_Y_BITS),
		.POS_X_BITS(update_intf.POS_X_BITS),
		.POS_Y_BITS(update_intf.POS_Y_BITS)
	) _inner_logic (
		.op(op),
		.state_intf(state_intf),
		.last_x(_last_x),
		.last_y(_last_y),
		.dir(_nxt_dir),
		.is_last_mvt(_is_last_mvt),

		.pulse_num_x(motors_intf.pulse_num_x),
		.pulse_num_y(motors_intf.pulse_num_y),
		.new_x(update_intf.new_x),
		.new_y(update_intf.new_y),
		.is_cw(_is_cw),
		.start_x(_start_x),
		.start_y(_start_y),
		.cur_x(_cur_x),
		.cur_y(_cur_y),
		.end_x(_end_x),
		.end_y(_end_y),
		.r_squared(_r_squared),
		.cur_r_squared(_cur_r_squared),
		.precise_crossing_axes(_precise_crossing_axes),
		.is_full_circle(_is_full_circle)
	);

	QuadrantFinder #(
		.NUM_BITS(NUM_BITS)
	) _cur_quadrant_finder (
		.relative_x(_cur_x),
		.relative_y(_cur_y),
		.quadrant(_cur_quadrant)
	);

	CircularOpHandler_DirectionFinder #(
		.NUM_BITS(NUM_BITS)
	) _dir_finder (
		.is_cw(_is_cw),
		.quadrant(_cur_quadrant),
		.r_squared(_r_squared),
		.cur_r_squared(_cur_r_squared),
		.dir(_nxt_dir)
	);

	CircularOpHandler_NumStepsCalculator #(
		.NUM_BITS(NUM_BITS)
	) _num_steps_calc (
		.is_cw(_is_cw),
		.start_x(_start_x),
		.start_y(_start_y),
		.end_x(_end_x),
		.end_y(_end_y),
		.r(_r),
		.precise_crossing_axes(_precise_crossing_axes),
		.is_full_circle(_is_full_circle),
		.num_steps(_num_steps)
	);

	IntSqrt #(
		.NUM_BITS(NUM_BITS)
	) _int_sqrt (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.num_in(_r_squared),
		.trigger(_sqrt_trigger),
		.sqrt_out(_r),
		.done(_sqrt_done),
		.rdy(_sqrt_rdy)
	);

	CircularOpHandler_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(handler_intf.trigger),
		.sqrt_done(_sqrt_done),
		.sqrt_rdy(_sqrt_rdy),
		.motors_done(motors_intf.done),
		.motors_rdy(motors_intf.rdy),
		.reached_num_steps(_reached_num_steps),
		
		.sqrt_trigger(_sqrt_trigger),
		.motors_trigger(motors_intf.trigger),
		.update_counter(_update_counter),
		.update_pos(update_intf.update),
		.done(handler_intf.done),
		.rdy(_rdy)
	);

	assign handler_intf.rdy = _rdy;
	assign _reached_num_steps = ((_num_steps == _steps_counter) | (~|_num_steps) | (_num_steps[STEP_BITS-1])) ? 1 : 0;
	assign motors_intf.servo_pos = SERVO_POS_DOWN;
	assign _is_last_mvt = _reached_num_steps;

	// sync logic
	always_ff @(posedge clk) begin
		if (reset) begin
			_last_x <= state_intf.cur_x;
			_last_y <= state_intf.cur_y;
			_steps_counter <= 0;
		end
		else if (clk_en) begin
			_last_x <= _last_x;
			_last_y <= _last_y;
			_steps_counter <= _steps_counter;

			if (_update_counter) begin
				_steps_counter <= _steps_counter + 1;
			end

			if (_rdy & handler_intf.trigger) begin
				_last_x <= state_intf.cur_x;
				_last_y <= state_intf.cur_y;
				_steps_counter <= 0;
			end
		end
		else begin
			_last_x <= _last_x;
			_last_y <= _last_y;
			_steps_counter <= _steps_counter;
		end
	end // always_ff

endmodule : CircularOpHandler
