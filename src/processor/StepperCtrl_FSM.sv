`include "../common/common.svh"

typedef enum {
	STEPPER_CTRL_RESET,
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
* :input counter_stop: '1' if requested number of pulses was already sent.
* :output working: Is the machine in the midst of working (sending pulses).
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
			STEPPER_CTRL_RESET: begin
				nxt_state = STEPPER_CTRL_STANDBY;
				reset_pulse_num_counter = 1;
				reset_pulse_width_counter = 1;
				if (trigger) begin
					nxt_state = STEPPER_CTRL_WORKING;
				end
			end

			STEPPER_CTRL_STANDBY: begin
				nxt_state = STEPPER_CTRL_STANDBY;
				if (trigger) begin
					reset_pulse_num_counter = 1;
					reset_pulse_width_counter = 1;
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
					reset_pulse_num_counter = 1;
					reset_pulse_width_counter = 1;
				end
				if (pulse_width_is_zero) begin
					nxt_state = STEPPER_CTRL_STANDBY;
					reset_pulse_num_counter = 1;
					reset_pulse_width_counter = 1;
				end
			end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			cur_state <= STEPPER_CTRL_RESET;
		end
		else if (clk_en) begin
			cur_state <= nxt_state;
		end
		else begin
			cur_state <= cur_state;
		end
	end // always_ff

endmodule : StepperCtrl_FSM

// typedef enum {
// 	STEPPER_CTRL_STANDBY,
// 	STEPPER_CTRL_WORKING
// } StepperCtrl_state;
// 
// module StepperCtrl_FSM (
// 	input logic clk,
// 	input logic reset,
// 	input logic clk_en,
// 	input logic trigger,
// 	input logic counter_stop,
// 
// 	output logic working
// );
// 
// 	StepperCtrl_state cur_state;
// 	StepperCtrl_state nxt_state;
// 
// 	always_comb begin
// 		case (cur_state)
// 			STEPPER_CTRL_STANDBY: begin
// 				working = 1'b0;
// 				nxt_state = STEPPER_CTRL_STANDBY;
// 				if (trigger) begin
// 					nxt_state = STEPPER_CTRL_WORKING;
// 				end
// 			end
// 			STEPPER_CTRL_WORKING: begin
// 				working = 1'b1;
// 				nxt_state = STEPPER_CTRL_WORKING;
// 				if (counter_stop) begin
// 					nxt_state = STEPPER_CTRL_STANDBY;
// 					working = 1'b0;
// 				end
// 			end
// 			// Default: shouldn't happen
// 		endcase
// 	end // always_comb
// 
// 	always_ff @(posedge clk) begin
// 		if (reset) begin
// 			cur_state <= STEPPER_CTRL_STANDBY;
// 		end
// 		else if (clk_en) begin
// 			cur_state <= nxt_state;
// 		end
// 		else begin
// 			cur_state <= cur_state;
// 		end
// 	end // always_ff
// 
// endmodule : StepperCtrl_FSM
