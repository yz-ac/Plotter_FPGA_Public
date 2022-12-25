module Timer_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic reached_zero,

	output logic working
);

	typedef enum {
		IDLE,
		WORKING
	} Timer_state;

	Timer_state _cur_state;
	Timer_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			working = 0;
			if (trigger) begin
				_nxt_state = WORKING;
			end
		end
		WORKING: begin
			_nxt_state = WORKING;
			working = 1;
			if (reached_zero) begin
				_nxt_state = IDLE;
			end
		end
		default: begin
			_nxt_state = IDLE;
			working = 0;
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

endmodule : Timer_FSM
