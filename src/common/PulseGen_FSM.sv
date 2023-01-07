typedef enum {
	PULSE_GEN_IDLE,
	PULSE_GEN_PREPARE,
	PULSE_GEN_WORKING
} PulseGen_state;

/**
* FSM for PulseGen Module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Logic enabling clock.
* :input trigger: Triggers pulse logic.
* :input counters_reached_target: PulseGen internal counters reached requested numbers.
* :output prepare: Logic in preparation state (buffer against races).
* :output done: Logic is finished.
* :output rdy: Ready to accept new triggers.
*/
module PulseGen_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic counters_reached_target,

	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		WORKING,
		DONE
	} PulseGen_state;

	PulseGen_state _cur_state;
	PulseGen_state _nxt_state;

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
			if (counters_reached_target) begin
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

endmodule : PulseGen_FSM
