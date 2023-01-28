`include "common/common.svh"

/**
* Checks if the number fits the argument field.
*
* :param MAX_ARG_BITS: Maximum number of bits in the field.
* :input num: Number to check.
* :output is_valid: Does the number fit the field.
*/
module ArgSizeCheck #(
	parameter MAX_ARG_BITS = `OP_ARG_BITS,
	// Not all edge cases are covered - twice the field width is sufficient.
	localparam NUM_BITS = MAX_ARG_BITS * 2
)
(
	input logic [NUM_BITS-1:0] num,
	output logic is_valid
);
	
	wire [NUM_BITS-2:0] _abs_num;

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _abs (
		.num(num),
		.out(_abs_num)
	);

	assign is_valid = (~|_abs_num[NUM_BITS-2:MAX_ARG_BITS-1]) ? 1 : 0;

endmodule : ArgSizeCheck
