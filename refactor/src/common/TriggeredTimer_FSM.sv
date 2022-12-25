/**
* Triggered Timer FSM.
*
* :input clk: System clock.
* :input reset: Resets the FSM.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers the logic.
* :input reached_zero: Timer reached zero.
* :output done: Counting is done.
* :output rdy: Ready to accept new triggers.
*/
module TriggeredTimer_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic reached_zero,

	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		WORKING,
		DONE
	} TriggeredTimer_state;

	TriggeredTimer_state _cur_state;
	TriggeredTimer_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 1;
			if (trigger) begin
				_nxt_state = WORKING;
				done = 0;
			end
		end
		WORKING: begin
			_nxt_state = WORKING;
			done = 0;
			rdy = 0;
			if (reached_zero) begin
				_nxt_state = DONE;
				done = 1;
			end
		end
		DONE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE;
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

endmodule : TriggeredTimer_FSM
