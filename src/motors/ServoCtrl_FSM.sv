import Servo_PKG::ServoPos_t;
import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;

import Servo_PKG::ServoDir_t;
import Servo_PKG::SERVO_DIR_UP;
import Servo_PKG::SERVO_DIR_DOWN;
import Servo_PKG::SERVO_DIR_STAY;

/**
* FSM for ServoCtrl.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers logic.
* :input timer_done: Is timer timing the servo movement stopped counting.
* :input timer_rdy: Is timer timing the servo movement rdy to be triggered.
* :input servo_pos: Requeated new servo position.
* :output timer_trigger: Triggers the timer to time servo movement.
* :output servo_dir: Servo rotation direction to reach new position.
* :output done: Logic is done.
* :output rdy: Logic ready to be triggered.
*/
module ServoCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic timer_done,
	input logic timer_rdy,
	input ServoPos_t servo_pos,

	output logic timer_trigger,
	output ServoDir_t servo_dir,
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE_UP,
		IDLE_DOWN,
		TRIGGER_TIMER_UP,
		TRIGGER_TIMER_DOWN,
		WORKING_UP_TO_DOWN,
		WORKING_DOWN_TO_UP,
		DONE_UP,
		DONE_DOWN
	} ServoCtrl_state;

	ServoCtrl_state _cur_state;
	ServoCtrl_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE_UP: begin
			_nxt_state = IDLE_UP;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_STAY;
			done = 1;
			rdy = 1;
			if (trigger) begin
				_nxt_state = DONE_UP;
				done = 0;
				if (servo_pos == SERVO_POS_DOWN && timer_rdy) begin
					_nxt_state = TRIGGER_TIMER_UP;
				end
			end
		end
		IDLE_DOWN: begin
			_nxt_state = IDLE_DOWN;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_STAY;
			done = 1;
			rdy = 1;
			if (trigger) begin
				_nxt_state = DONE_DOWN;
				done = 0;
				if (servo_pos == SERVO_POS_UP && timer_rdy) begin
					_nxt_state = TRIGGER_TIMER_DOWN;
				end
			end
		end
		TRIGGER_TIMER_UP: begin
			_nxt_state = TRIGGER_TIMER_UP;
			timer_trigger = 1;
			servo_dir = SERVO_DIR_STAY;
			done = 0;
			rdy = 0;
			if (timer_rdy == 0) begin
				_nxt_state = WORKING_UP_TO_DOWN;
			end
		end
		TRIGGER_TIMER_DOWN: begin
			_nxt_state = TRIGGER_TIMER_DOWN;
			timer_trigger = 1;
			servo_dir = SERVO_DIR_STAY;
			done = 0;
			rdy = 0;
			if (timer_rdy == 0) begin
				_nxt_state = WORKING_DOWN_TO_UP;
			end
		end
		WORKING_UP_TO_DOWN: begin
			_nxt_state = WORKING_UP_TO_DOWN;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_DOWN;
			done = 0;
			rdy = 0;
			if (timer_done == 1) begin
				_nxt_state = DONE_DOWN;
				done = 1;
			end
		end
		WORKING_DOWN_TO_UP: begin
			_nxt_state = WORKING_DOWN_TO_UP;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_UP;
			done = 0;
			rdy = 0;
			if (timer_done == 1) begin
				_nxt_state = DONE_UP;
				done = 1;
			end
		end
		DONE_UP: begin
			_nxt_state = IDLE_UP;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_STAY;
			done = 1;
			rdy = 0;
		end
		DONE_DOWN: begin
			_nxt_state = IDLE_DOWN;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_STAY;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE_UP;
			timer_trigger = 0;
			servo_dir = SERVO_DIR_STAY;
			done = 0;
			rdy = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= IDLE_DOWN;
		end
		else if (clk_en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : ServoCtrl_FSM
