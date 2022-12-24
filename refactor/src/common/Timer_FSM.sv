typedef enum {
	TIMER_IDLE,
	TIMER_WORKING
} Timer_state;

module Timer_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic reached_target,

	output logic working
);

	Timer_state _cur_state;
	Timer_state _nxt_state;

	always_comb begin
		case (_cur_state)
		TIMER_IDLE: begin
			_nxt_state = TIMER_IDLE;
			working = 0;
			if (trigger) begin
				_nxt_state = TIMER_WORKING;
				working = 1;
			end
		end
		TIMER_WORKING: begin
			_nxt_state = TIMER_WORKING;
			working = 1;
			if (reached_target) begin
				_nxt_state = TIMER_IDLE;
				working = 0;
			end
		end
		default: begin
			_nxt_state = TIMER_IDLE;
			working = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= TIMER_IDLE;
		end
		else if (clk_en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : Timer_FSM
