/**
* FSM for linear opcode handler.
* 
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers module logic.
* :input motors_done: Is motor logic done.
* :input motors_rdy: Are motors ready to accept trigger.
* :input reached_num_steps: Reached number of steps in the linear motion.
* :output motors_trigger: Triggers motor logic.
* :output update_counter: Update steps counter.
* :output update_pos: Update current position.
* :output done: Module logic done.
* :output rdy: Ready to accept triggers.
*/
module LinearOpHandler_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic motors_done,
	input logic motors_rdy,
	input logic reached_num_steps,

	output logic motors_trigger,
	output logic update_counter,
	output logic update_pos,
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		WAIT_MOTORS_RDY,
		TRIGGER_MOTORS,
		WAIT_MOTORS_DONE,
		UPDATE_COUNTER_AND_POS,
		LAST_TRIGGER_MOTORS,
		LAST_WAIT_MOTORS_DONE,
		LAST_UPDATE_POS,
		DONE
	} LinearOpHandler_state;

	LinearOpHandler_state _cur_state;
	LinearOpHandler_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 1;
			rdy = 1;

			if (trigger) begin
				_nxt_state = WAIT_MOTORS_RDY;
				done = 0;
			end
		end
		WAIT_MOTORS_RDY: begin
			_nxt_state = WAIT_MOTORS_RDY;
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
		TRIGGER_MOTORS: begin
			_nxt_state = TRIGGER_MOTORS;
			motors_trigger = 1;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;

			if (!motors_rdy) begin
				_nxt_state = WAIT_MOTORS_DONE;
			end
		end
		WAIT_MOTORS_DONE: begin
			_nxt_state = WAIT_MOTORS_DONE;
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
			motors_trigger = 0;
			update_counter = 1;
			update_pos = 1;
			done = 0;
			rdy = 0;
		end
		LAST_TRIGGER_MOTORS: begin
			_nxt_state = LAST_TRIGGER_MOTORS;
			motors_trigger = 1;
			update_counter = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;

			if (!motors_rdy) begin
				_nxt_state = LAST_WAIT_MOTORS_DONE;
			end
		end
		LAST_WAIT_MOTORS_DONE: begin
			_nxt_state = LAST_WAIT_MOTORS_DONE;
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
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 1;
			done = 0;
			rdy = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			motors_trigger = 0;
			update_counter = 0;
			update_pos = 0;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE;
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

endmodule : LinearOpHandler_FSM
