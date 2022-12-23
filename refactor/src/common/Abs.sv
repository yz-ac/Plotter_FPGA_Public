`include "common/common.svh"

/**
* Absolute value.
*
* :param NUM_BITS: Field width of the number (including sign bit).
* :input num: The signed number.
* :output out: The unsigned number.
*/
module Abs #(
	NUM_BITS = `BYTE_BITS
)
(
	input logic [NUM_BITS-1:0] num,

	output logic [NUM_BITS-2:0] out
);

	always_comb begin
		out = num[NUM_BITS-2:0];
		if (num[NUM_BITS-1]) begin
			// Two's complement
			out = (~(num[NUM_BITS-2:0])) + 1;
		end
	end // always_comb

endmodule : Abs
