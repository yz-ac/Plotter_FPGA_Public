`include "../common/common.svh"

typedef enum {
	STANDBY,
	TRIGGER_HOLD_BOTH,
	TRIGGER_HOLD_X,
	TRIGGER_HOLD_Y,
	WORKING
} StepperCtrlXY_state;

/**
* FSM for StepperCtrlXY module.
*
* :input clk: System clock.
* :input reset: Reset the FSM.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers pulses for the steppers.
* :input working_x: Is the StepperCtrl for the X axis working.
* :input working_y: Is the StepperCtrl for the Y axis working.
* :output trigger_x: Trigger for the X axis StepperCtrl.
* :output trigger_y: Trigger for the Y axis StepperCtrl.
* :output is_standby: Is the module in standby (accepting new triggers).
*/
module StepperCtrlXY_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic working_x,
	input logic working_y,

	output logic trigger_x,
	output logic trigger_y,
	output logic is_standby
);

	StepperCtrlXY_state cur_state;
	StepperCtrlXY_state nxt_state;

	always_comb begin
		trigger_x = 1'b0;
		trigger_y = 1'b0;
		is_standby = 1'b0;
		case (cur_state)
			STANDBY: begin
				nxt_state = STANDBY;
				is_standby = 1'b1;
				if (trigger) begin
					nxt_state = TRIGGER_HOLD_BOTH;
				end
			end
			TRIGGER_HOLD_BOTH: begin
				trigger_x = 1'b1;
				trigger_y = 1'b1;
				nxt_state = TRIGGER_HOLD_BOTH;
				if (working_x) begin
					nxt_state = TRIGGER_HOLD_Y;
				end
				if (working_y) begin
					nxt_state = TRIGGER_HOLD_X;
				end
				if (working_x & working_y) begin
					nxt_state = WORKING;
				end
			end
			TRIGGER_HOLD_X: begin
				trigger_x = 1'b1;
				nxt_state = TRIGGER_HOLD_X;
				if (working_x) begin
					nxt_state = WORKING;
				end
			end
			TRIGGER_HOLD_Y: begin
				trigger_y = 1'b1;
				nxt_state = TRIGGER_HOLD_Y;
				if (working_y) begin
					nxt_state = WORKING;
				end
			end
			WORKING: begin
				nxt_state = WORKING;
				if ((!working_x) & (!working_y)) begin
					nxt_state = STANDBY;
				end
			end
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

endmodule : StepperCtrlXY_FSM
