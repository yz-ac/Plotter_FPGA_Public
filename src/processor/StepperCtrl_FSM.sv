`include "../common/common.svh"

typedef enum {
	STEPPER_CTRL_STANDBY,
	STEPPER_CTRL_WORKING
} StepperCtrl_state;

/**
* FSM for StepperCtrl module.
*
* :input clk: System clock.
* :input reset: Reset the FSM.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers pulses for the stepper.
* :input pulse_num_count_reached_target: Counter counting number of pulses reached requested number.
* :input pulse_width_count_reached_target: Counter counting clocks for pulse width reached requested number.
* :input pulse_width_is_zero: Requested pulse width is zero.
* :output working: Is the module in the middle of generating pulses for the stepper.
* :output reset_pulse_num_counter: Synchrounous reset of the counter which counts the number of pulses.
* :output reset_pulse_width_counter: Synchronous reset of the counter which counts clocks for pulse width.
* :output enable_pulse_num_counter: Enable increment of counter counting the number of pulses.
* :output enable_pulse_width_counter: Enable increment of counter counting clocks for pulse width.
*/
module StepperCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,

	input logic pulse_num_count_reached_target,
	input logic pulse_width_count_reached_target,
	input logic pulse_width_is_zero,

	output logic working,
	output logic reset_pulse_num_counter,
	output logic reset_pulse_width_counter,
	output logic enable_pulse_num_counter,
	output logic enable_pulse_width_counter
);

	StepperCtrl_state cur_state;
	StepperCtrl_state nxt_state;

	always_comb begin
		reset_pulse_num_counter = 0;
		reset_pulse_width_counter = 0;
		enable_pulse_num_counter = 0;
		enable_pulse_width_counter = 0;
		working = 0;
		case (cur_state)
			STEPPER_CTRL_STANDBY: begin
				nxt_state = STEPPER_CTRL_STANDBY;
				reset_pulse_num_counter = 1;
				reset_pulse_width_counter = 1;
				if (trigger) begin
					nxt_state = STEPPER_CTRL_WORKING;
				end
			end

			STEPPER_CTRL_WORKING: begin
				nxt_state = STEPPER_CTRL_WORKING;
				working = 1;
				enable_pulse_width_counter = 1;

				if (pulse_width_count_reached_target) begin
					reset_pulse_width_counter = 1;
					enable_pulse_num_counter = 1;
				end
				if (pulse_num_count_reached_target & pulse_width_count_reached_target) begin
					nxt_state = STEPPER_CTRL_STANDBY;
					reset_pulse_width_counter = 1;
					reset_pulse_num_counter = 1;
				end
				if (pulse_width_is_zero) begin
					nxt_state = STEPPER_CTRL_STANDBY;
					reset_pulse_width_counter = 1;
					reset_pulse_num_counter = 1;
				end
			end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			cur_state <= STEPPER_CTRL_STANDBY;
		end
		else if (clk_en) begin
			cur_state <= nxt_state;
		end
		else begin
			cur_state <= cur_state;
		end
	end // always_ff

endmodule : StepperCtrl_FSM
