`include "../common/common.svh"

typedef enum {
	STANDBY,
	WORKING
} StepperCtrl_state;

/**
* FSM for StepperCtrl module.
*
* :input clk: System clock.
* :input reset: Reset the FSM.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers pulses for the stepper.
* :input counter_stop: '1' if requested number of pulses was already sent.
* :output working: Is the machine in the midst of working (sending pulses).
*/
module StepperCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic counter_stop,

	output logic working
);

	StepperCtrl_state cur_state;
	StepperCtrl_state nxt_state;

	always_comb begin
		case (cur_state)
			STANDBY: begin
				working = 1'b0;
				nxt_state = STANDBY;
				if (trigger) begin
					nxt_state = WORKING;
				end
			end
			WORKING: begin
				working = 1'b1;
				nxt_state = WORKING;
				if (counter_stop) begin
					nxt_state = STANDBY;
					working = 1'b0;
				end
			end
			// Default: shouldn't happen
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			cur_state <= STANDBY;
		end
		else if (clk_en) begin
			cur_state <= nxt_state;
		end
		else begin
			cur_state <= cur_state;
		end
	end // always_ff

endmodule : StepperCtrl_FSM
