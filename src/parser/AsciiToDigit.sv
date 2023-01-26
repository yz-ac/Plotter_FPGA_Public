`include "common/common.svh"

/**
* Converts ascii digit to numeric digit (if input is not an ascii digit - GIGO).
*
* :input char_in: ASCII character of a digit.
* :output digit_out: Numeric digit.
*/
module AsciiToDigit (
	input logic [`BYTE_BITS-1:0] char_in,

	output logic [`DIGIT_BITS-1:0] digit_out
);

	wire [`BYTE_BITS-1:0] _digit_ext;

	assign _digit_ext = char_in ^ 'h30;
	assign digit_out = _digit_ext[`DIGIT_BITS-1:0];

endmodule : AsciiToDigit
