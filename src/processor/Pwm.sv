`include "../common/common.svh"

/**
* PWM module, outputs '1' with a given duty cycle.
* Works by using an internal counter.
* Duty cycle and period can only be changed when counter resets to prevent glitches.
*
* :param PERIOD_BITS: Number of bits in the counter.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input period: The period of the PWM.
* :input duty_cycle: The duty cycle of the PWM.
* :output out: Output of the PWM.
*/
module Pwm #(
	parameter PERIOD_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic [PERIOD_BITS-1:0] period,
	input logic [PERIOD_BITS-1:0] duty_cycle,

	output logic out
);

	reg [PERIOD_BITS-1:0] counter;
	reg [PERIOD_BITS-1:0] saved_period;
	reg [PERIOD_BITS-1:0] saved_duty_cycle;

	assign out = (counter <= saved_duty_cycle) ? 1'b1 : 1'b0;

	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 1;
			saved_period <= period;
			saved_duty_cycle <= duty_cycle;
		end
		else if (clk_en) begin
			counter <= counter + 1;
			saved_period <= saved_period;
			saved_duty_cycle <= saved_duty_cycle;

			if (counter == saved_period) begin
				counter <= 1;
				saved_period <= period;
				
				// Duty cycle of 0% if duty cycle not valid (larger than period)
				if (duty_cycle <= period) begin
					saved_duty_cycle <= duty_cycle;
				end
				else begin
					saved_duty_cycle <= 0;
				end
			end
		end
		else begin
			counter <= counter;
			saved_period <= saved_period;
			saved_duty_cycle <= saved_duty_cycle;
		end
	end // always_ff

endmodule : Pwm
