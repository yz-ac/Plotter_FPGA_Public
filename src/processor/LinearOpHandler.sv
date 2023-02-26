import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;
import Position_PKG::PosDirection_t;

/**
* Module to handle and process linear movement opcodes.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input op: Current opcode being processed.
* :iface handler_intf: Opcode handler interface.
* :iface state_intf: Interface to get current position and mode.
* :iface update_intf: Interface to update current position.
* :iface motors_intf: Interface to control motors.
*/
module LinearOpHandler (
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
	localparam NUM_BITS = state_intf.POS_X_BITS + state_intf.POS_Y_BITS - 1;
	localparam STEP_BITS = NUM_BITS + 3;

	// wires and registers
	wire _rdy;
	reg [state_intf.POS_X_BITS-1:0] _last_x;
	reg [state_intf.POS_Y_BITS-1:0] _last_y;

	wire [NUM_BITS-1:0] _start_x;
	wire [NUM_BITS-1:0] _start_y;
	wire [NUM_BITS-1:0] _cur_x;
	wire [NUM_BITS-1:0] _cur_y;
	wire [NUM_BITS-1:0] _end_x;
	wire [NUM_BITS-1:0] _end_y;

	PosDirection_t _nxt_dir;

	wire _is_last_mvt;
	wire _update_counter;

	wire [STEP_BITS-1:0] _num_steps;
	reg [STEP_BITS-1:0] _steps_counter;
	wire _reached_num_steps;

	// modules
	LinearOpHandler_InnerLogic #(
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
		.start_x(_start_x),
		.start_y(_start_y),
		.cur_x(_cur_x),
		.cur_y(_cur_y),
		.end_x(_end_x),
		.end_y(_end_y)
	);

	LinearOpHandler_DirectionFinder #(
		.NUM_BITS(NUM_BITS)
	) _dir_finder (
		.start_x(_start_x),
		.start_y(_start_y),
		.cur_x(_cur_x),
		.cur_y(_cur_y),
		.end_x(_end_x),
		.end_y(_end_y),
		.dir(_nxt_dir)
	);

	LinearOpHandler_NumStepsCalculator #(
		.NUM_BITS(NUM_BITS)
	) _num_steps_calc (
		.start_x(_start_x),
		.start_y(_start_y),
		.end_x(_end_x),
		.end_y(_end_y),
		.num_steps(_num_steps)
	);

	LinearOpHandler_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(handler_intf.trigger),
		.motors_done(motors_intf.done),
		.motors_rdy(motors_intf.rdy),
		.reached_num_steps(_reached_num_steps),

		.motors_trigger(motors_intf.trigger),
		.update_counter(_update_counter),
		.update_pos(update_intf.update),
		.done(handler_intf.done),
		.rdy(_rdy)
	);

	assign handler_intf.rdy = _rdy;
	assign _reached_num_steps = ((_num_steps == _steps_counter) | (~|_num_steps)) ? 1 : 0;
	assign motors_intf.servo_pos = (op.cmd == OP_CMD_G01) ? (SERVO_POS_DOWN) : (SERVO_POS_UP);
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

endmodule : LinearOpHandler
