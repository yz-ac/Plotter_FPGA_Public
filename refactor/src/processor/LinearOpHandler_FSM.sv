/**
* FSM for linear opcode handler.
* 
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers module logic.
* :input motors_done: Is motor logic done.
* :input motors_rdy: Are motors ready to accept trigger.
* :output motors_trigger: Triggers motor logic.
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

	output logic motors_trigger,
	output logic update_pos,
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		TRIGGER_MOTORS,
		WAIT_MOTORS,
		UPDATE_POS,
		DONE
	} LinearOpHandler_state;

	LinearOpHandler_state _cur_state;
	LinearOpHandler_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			motors_trigger = 0;
			update_pos = 0;
			done = 1;
			rdy = 1;
			if (trigger & motors_rdy) begin
				_nxt_state = TRIGGER_MOTORS;
				done = 0;
			end
		end
		TRIGGER_MOTORS: begin
			_nxt_state = TRIGGER_MOTORS;
			motors_trigger = 1;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (!motors_rdy) begin
				_nxt_state = WAIT_MOTORS;
			end
		end
		WAIT_MOTORS: begin
			_nxt_state = WAIT_MOTORS;
			motors_trigger = 0;
			update_pos = 0;
			done = 0;
			rdy = 0;
			if (motors_done) begin
				_nxt_state = UPDATE_POS;
			end
		end
		UPDATE_POS: begin
			_nxt_state = DONE;
			motors_trigger = 0;
			update_pos = 1;
			done = 0;
			rdy = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			motors_trigger = 0;
			update_pos = 0;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE;
			motors_trigger = 0;
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
