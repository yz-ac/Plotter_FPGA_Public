/**
* FSM for CircularOpHandler module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers circular motion.
* :input sqrt_done: Is sqrt module finished calculating.
* :input sqrt_rdy: Is sqrt module ready to accept triggers.
* :input motors_done: Is motors control module done.
* :input motors_rdy: Is motors control module ready to accept triggers.
* :input reached_num_steps: Reached number of steps in the circular motion.
* :output sqrt_trigger: Triggers sqrt module.
* :output motors_trigger: Trigger motors control module.
* :output update_counter: Update steps counter.
* :output update_pos: Update current position.
* :output done: Movement done.
* :output rdy: Ready to accept triggers.
*/
module CircularOpHandler_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic sqrt_done,
	input logic sqrt_rdy,
	input logic motors_done,
	input logic motors_rdy,
	input logic reached_num_steps,

	output logic sqrt_trigger,
	output logic motors_trigger,
	output logic update_counter,
	output logic update_pos,
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		TRIGGER_SQRT,
		WAIT_SQRT,
		WAIT_MOTORS_RDY,
		TRIGGER_MOTORS,
		WAIT_MOTORS,
		UPDATE_COUNTER_AND_POS,
		LAST_TRIGGER_MOTORS,
		LAST_WAIT_MOTORS,
		LAST_UPDATE_POS,
		DONE
	} CircularOpHandler_state;

	CircularOpHandler_state _cur_state;
	CircularOpHandler_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 1;
			rdy = 1;
			if (trigger & sqrt_rdy) begin
				_nxt_state = TRIGGER_SQRT;
				done = 0;
			end
		end
		TRIGGER_SQRT: begin
			_nxt_state = TRIGGER_SQRT;
			sqrt_trigger = 1;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (!sqrt_rdy) begin
				_nxt_state = WAIT_SQRT;
			end
		end
		WAIT_SQRT: begin
			_nxt_state = WAIT_SQRT;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (sqrt_done & motors_rdy) begin
				_nxt_state = TRIGGER_MOTORS;
			end
		end
		TRIGGER_MOTORS: begin
			_nxt_state = TRIGGER_MOTORS;
			sqrt_trigger = 0;
			motors_trigger = 1;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (!motors_rdy) begin
				_nxt_state = WAIT_MOTORS;
			end
		end
		WAIT_MOTORS: begin
			_nxt_state = WAIT_MOTORS;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (motors_done) begin
				_nxt_state = UPDATE_COUNTER_AND_POS;
			end
		end
		UPDATE_COUNTER_AND_POS: begin
			_nxt_state = WAIT_MOTORS_RDY;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 1;
			update_pos = 1;
			done = 0;
			rdy = 0;
		end
		WAIT_MOTORS_RDY: begin
			_nxt_state = WAIT_MOTORS_RDY;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (motors_rdy) begin
				_nxt_state = TRIGGER_MOTORS;
				if (reached_num_steps) begin
					_nxt_state = LAST_TRIGGER_MOTORS;
				end
			end
		end
		LAST_TRIGGER_MOTORS: begin
			_nxt_state = LAST_TRIGGER_MOTORS;
			sqrt_trigger = 0;
			motors_trigger = 1;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (!motors_rdy) begin
				_nxt_state = LAST_WAIT_MOTORS;
			end
		end
		LAST_WAIT_MOTORS: begin
			_nxt_state = LAST_UPDATE_POS;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (motors_done) begin
				_nxt_state = LAST_UPDATE_POS;
			end
		end
		LAST_UPDATE_POS: begin
			_nxt_state = DONE;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 1;
			done = 0;
			rdy = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE;
			sqrt_trigger = 0;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 1;
			rdy = 1;
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

endmodule : CircularOpHandler_FSM
