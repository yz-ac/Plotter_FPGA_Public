/**
* FSM for integer sqrt.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers computation.
* :input found: Is integer sqrt of number found.
* :output done: Computation is done.
* :output rdy: Ready to accept triggers.
*/
module IntSqrt_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic found,

	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		WORKING,
		DONE
	} IntSqrt_state;

	IntSqrt_state _cur_state;
	IntSqrt_state _nxt_state;

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
			if (found) begin
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

endmodule : IntSqrt_FSM
