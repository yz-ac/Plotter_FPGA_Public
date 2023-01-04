import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;

/**
* Module to handler and process linear movement opcodes.
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

	wire _rdy;
	reg [state_intf.POS_X_BITS-1:0] _last_x;
	reg [state_intf.POS_Y_BITS-1:0] _last_y;

	LinearOpHandler_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(handler_intf.trigger),
		.motors_done(motors_intf.done),
		.motors_rdy(motors_intf.rdy),
		.motors_trigger(motors_intf.trigger),
		.update_pos(update_intf.update),
		.done(handler_intf.done),
		.rdy(_rdy)
	);

	assign handler_intf.rdy = _rdy;

	always_comb begin : __servo_pos
		motors_intf.servo_pos = SERVO_POS_UP;
		if (op.cmd == OP_CMD_G01) begin
			motors_intf.servo_pos = SERVO_POS_DOWN;
		end
	end : __servo_pos

	always_comb begin : __motor_pulses
		motors_intf.pulse_num_x = op.arg_1;
		motors_intf.pulse_num_y = op.arg_2;
		if (state_intf.is_absolute) begin
			motors_intf.pulse_num_x = op.arg_1 - _last_x;
			motors_intf.pulse_num_y = op.arg_2 - _last_y;
		end
	end : __motor_pulses

	always_comb begin : __pos_update
		update_intf.new_x = _last_x + op.arg_1;
		update_intf.new_y = _last_y + op.arg_2;
		if (state_intf.is_absolute) begin
			update_intf.new_x = op.arg_1;
			update_intf.new_y = op.arg_2;
		end
	end : __pos_update

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_x <= state_intf.cur_x;
			_last_y <= state_intf.cur_y;
		end
		else if (clk_en) begin
			_last_x <= _last_x;
			_last_y <= _last_y;
			if (_rdy & handler_intf.trigger) begin
				_last_x <= state_intf.cur_x;
				_last_y <= state_intf.cur_y;
			end
		end
		else begin
			_last_x <= _last_x;
			_last_y <= _last_y;
		end
	end // always_ff

endmodule : LinearOpHandler
