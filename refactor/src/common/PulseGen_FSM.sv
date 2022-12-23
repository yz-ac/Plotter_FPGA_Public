`include "common/common.svh"

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
* :input en: Enables the module.
* :input trigger: Triggers pulse logic.
* :input counters_reached_target: PulseGen internal counters reached requested
* numbers.
* :output prepare: Logic in preparation state (buffer against races).
* :output working: Logic in working state.
*/
module PulseGen_FSM (
	input logic clk,
	input logic reset,
	input logic en,
	input logic trigger,
	input logic counters_reached_target,

	output logic prepare,
	output logic working
);

	PulseGen_state _cur_state;
	PulseGen_state _nxt_state;

	always_comb begin
		case (_cur_state)
		PULSE_GEN_IDLE: begin
			_nxt_state = PULSE_GEN_IDLE;
			prepare = 0;
			working = 0;
			if (trigger) begin
				_nxt_state = PULSE_GEN_PREPARE;
			end
		end

		PULSE_GEN_PREPARE: begin
			// Buffer state to prevent races (between deglitch and new trigger - which makes first pulse shorter)
			_nxt_state = PULSE_GEN_WORKING;
			prepare = 1;
			working = 1;
		end

		PULSE_GEN_WORKING: begin
			_nxt_state = PULSE_GEN_WORKING;
			prepare = 0;
			working = 1;
			if (counters_reached_target) begin
				_nxt_state = PULSE_GEN_IDLE;
			end
		end

		default: begin
			_nxt_state = PULSE_GEN_IDLE;
			prepare = 0;
			working = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= PULSE_GEN_IDLE;
		end
		else if (en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : PulseGen_FSM
