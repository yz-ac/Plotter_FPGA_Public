`include "common/common.svh"

/**
* Multiplier module.
*
* :param NUM_IN_BITS: Field width of input number.
* :param NUM_MULT: Multiplier.
* :input num_in: Input number.
* :output num_out: Product of input number and multiplier.
*/
module Multiplier #(
	parameter NUM_IN_BITS = `BYTE_BITS,
	parameter NUM_MULT = 2,
	localparam NUM_OUT_BITS = NUM_IN_BITS + $clog2(NUM_MULT)
)
(
	input logic [NUM_IN_BITS-1:0] num_in,
	output logic [NUM_OUT_BITS-1:0] num_out
);

	wire [NUM_OUT_BITS-1:0] _ext_num;

	assign _ext_num = {{NUM_OUT_BITS-NUM_IN_BITS{num_in[NUM_IN_BITS-1]}}, num_in[NUM_IN_BITS-1:0]};
	assign num_out = _ext_num * NUM_MULT;

endmodule : Multiplier
