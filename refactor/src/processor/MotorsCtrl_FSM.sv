/**
* FSM for motors control - ensures stepper movement comes after servo is
* finished.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input motors_trigger: Motors module is triggered.
* :input servo_done: Servo control logic is done.
* :input servo_rdy: Servo control logic is ready to accept triggers.
* :input steppers_done: Steppers control logic is done.
* :input steppers_rdy: Steppers control logic is ready to accept triggers.
* :output motors_done: Motors control logic is done.
* :output motors_rdy: Motors control logic is ready to accept triggers.
* :output servo_trigger: Triggers servo logic.
* :output steppers_trigger: Triggers steppers logic.
*/
module MotorsCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic motors_trigger,
	input logic servo_done,
	input logic servo_rdy,
	input logic steppers_done,
	input logic steppers_rdy,

	output logic motors_done,
	output logic motors_rdy,
	output logic servo_trigger,
	output logic steppers_trigger
);

	typedef enum {
		IDLE,
		TRIGGER_SERVO,
		WAIT_SERVO,
		TRIGGER_STEPPERS,
		WAIT_STEPPERS,
		DONE
	} MotorsCtrl_state;

	MotorsCtrl_state _cur_state;
	MotorsCtrl_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			motors_done = 1;
			motors_rdy = 1;
			servo_trigger = 0;
			steppers_trigger = 0;
			if (motors_trigger & servo_rdy) begin
				_nxt_state = TRIGGER_SERVO;
				motors_done = 0;
			end
		end
		TRIGGER_SERVO: begin
			_nxt_state = TRIGGER_SERVO;
			motors_done = 0;
			motors_rdy = 0;
			servo_trigger = 1;
			steppers_trigger = 0;
			if (!servo_rdy) begin
				_nxt_state = WAIT_SERVO;
			end
		end
		WAIT_SERVO: begin
			_nxt_state = WAIT_SERVO;
			motors_done = 0;
			motors_rdy = 0;
			servo_trigger = 0;
			steppers_trigger = 0;
			if (servo_done & steppers_rdy) begin
				_nxt_state = TRIGGER_STEPPERS;
			end
		end
		TRIGGER_STEPPERS: begin
			_nxt_state = TRIGGER_STEPPERS;
			motors_done = 0;
			motors_rdy = 0;
			servo_trigger = 0;
			steppers_trigger = 1;
			if (!steppers_rdy) begin
				_nxt_state = WAIT_STEPPERS;
			end
		end
		WAIT_STEPPERS: begin
			_nxt_state = WAIT_STEPPERS;
			motors_done = 0;
			motors_rdy = 0;
			servo_trigger = 0;
			steppers_trigger = 0;
			if (steppers_done) begin
				_nxt_state = DONE;
				motors_done = 1;
			end
		end
		DONE: begin
			_nxt_state = IDLE;
			motors_done = 1;
			motors_rdy = 0;
			servo_trigger = 0;
			steppers_trigger = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= IDLE;
		end
		else if (clk_en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : MotorsCtrl_FSM
