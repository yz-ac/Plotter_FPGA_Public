`include "common/common.svh"

/**
* Builds a number from decimal digits.
*
* :param NUM_BITS: Field width of output number.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input zero: Zeros the number.
* :input is_negative: Is the number negative.
* :input digit: Next digit to add.
* :input advance: Advance the number (multiply by ten and add digit).
* :output num: The number being built.
*/
module NumberBuilder #(
	parameter NUM_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic zero,
	input logic is_negative,
	input logic [`DIGIT_BITS-1:0] digit,
	input logic advance,

	output logic [NUM_BITS-1:0] num
);

	wire [NUM_BITS-1:0] _ext_digit;
	reg [NUM_BITS-1:0] _num;

	assign _ext_digit = {{NUM_BITS-`DIGIT_BITS{1'b0}}, digit[`DIGIT_BITS-1:0]};
	
	always_comb begin : __output_num
		num = _num;
		if (is_negative) begin
			// Two's complement
			num = (~_num[NUM_BITS-1:0]) + 1;
		end
	end : __output_num

	always_ff @(posedge clk) begin
		if (reset) begin
			_num <= 0;
		end
		else if (clk_en) begin
			_num <= _num;
			if (advance) begin
				_num <= (_num * 10) + _ext_digit;
			end
			if (zero) begin
				_num <= 0;
			end
		end
		else begin
			_num <= _num;
		end
	end // always_ff

endmodule : NumberBuilder
