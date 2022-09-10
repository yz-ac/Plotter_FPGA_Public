`include "./common.svh"

/**
* Generates a clk_en signal to divide frequency of clock.
* (NOTE: Duty Cycle is not preserved).
* Period can only be changed when output is high to prevent glitches.
* Note that signal is delayed in relation to clk, exercise extreme caution when using with period = 1.
*
* :param PREIOD_BITS: Number of bits for the period value.
* :input clk: System clock.
* :input reset: Resets the module.
* :input enable: Enables the module, if enable is '0' the state is saved
*				 (the counter is not reset).
* :input period: The period (in system clocks) of the generated signal.
* :output out: '1' every 'period' clocks, '0' otherwise.
*/
module ClockEnabler #(
	PERIOD_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic enable,
	input logic [PERIOD_BITS-1:0] period,

	output logic out
);

	reg [PERIOD_BITS-1:0] counter;
	reg [PERIOD_BITS-1:0] saved_period;

	always_comb begin
		out = 0;

		// If reached counter, output rises for one clk
		if (counter == saved_period) begin
			out = enable;
		end

		// If period is 0, output is 0
		if (~|saved_period) begin
			out = 0;
		end

		// If period is 1 output is clk
		if (saved_period == 1) begin
			out = clk;
		end
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 1;
			saved_period <= period;
		end
		else begin
			counter <= counter + enable;
			saved_period <= saved_period;

			if (counter == saved_period) begin
				counter <= 1;
				saved_period <= period;
			end
		end
	end // always_ff

endmodule : ClockEnabler
