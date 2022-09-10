`include "./common.svh"

/**
* Divides the frequency of the given signal.
* (NOTE: duty cycle is NOT preserved).
* Division value can only be changed when output is high to prevent glitches.
*
* :param DIV_BITS: Number of bits for the division value.
* :input clk: System clock.
* :input reset: Resets the module.
* :input signal_in: Signal whose frequency is being divided.
* :input div_val: Value by which the frequency is divided.
* :output signal_out: The new signal with lower frequency.
*/
module FreqDivider #(
	DIV_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic signal_in,
	input logic [DIV_BITS-1:0] div_val,

	output logic signal_out
);

	reg [DIV_BITS-1:0] counter;
	reg [DIV_BITS-1:0] saved_div_val;

	always_comb begin
		signal_out = 0;
		// If reached counter, output rises for one clk
		if (counter == saved_div_val) begin
			signal_out = 1;
		end

		// If div_val is 0, output is always 0
		if (~|saved_div_val) begin
			signal_out = 0;
		end

		// If div val is 1, output is equal to input
		if (div_val == 1) begin
			signal_out = signal_in;
		end
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 1;
			saved_div_val <= div_val;
		end
		else if (signal_in) begin
			counter <= counter + 1;
			saved_div_val <= saved_div_val;

			if (counter == saved_div_val) begin
				counter <= 1;
				saved_div_val <= div_val;
			end

		end
		else begin
			counter <= counter;
			saved_div_val <= saved_div_val;
		end
	end // always_ff

endmodule : FreqDivider
