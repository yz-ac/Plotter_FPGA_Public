module DummyOpHandler_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		DONE
	} DummyOpHandler_state;

	DummyOpHandler_state _cur_state;
	DummyOpHandler_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 1;
			if (trigger) begin
				_nxt_state = DONE;
				done = 0;
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

endmodule : DummyOpHandler_FSM
