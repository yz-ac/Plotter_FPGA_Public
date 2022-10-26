`include "../common/common.svh"

/**
* Calculates the absolute value of a number.
* 
* :param BITS: Number of bits in the input number (including sign bit).
* :input in: Input number (including sign bit).
* :output out: Absolute value number (NOT including sign bit).
*/
module Abs #(
	BITS = `BYTE_BITS
)
(
	input logic [BITS-1:0] in,
	
	output logic [BITS-2:0] out
);

	always_comb begin
		out = in[BITS-2:0];

		// Negative - two's complements
		if (in[BITS-1]) begin
			out = (~in[BITS-2:0]) + 1;
		end
	end // always_comb

endmodule : Abs
