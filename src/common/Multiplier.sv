`include "common/common.svh"

/**
* Multiplier module.
*
* :param NUM_IN_BITS: Field width of input number.
* :param MULT_BITS: Field width of multiplier.
* :input num_in: Input number.
* :input mult: Multiplier.
* :output num_out: Product of input number and multiplier.
*/
module Multiplier #(
	parameter NUM_IN_BITS = `BYTE_BITS,
	parameter MULT_BITS = `BYTE_BITS,
	localparam NUM_OUT_BITS = NUM_IN_BITS + MULT_BITS - 1
)
(
	input logic [NUM_IN_BITS-1:0] num_in,
	input logic [MULT_BITS-1:0] mult,
	output logic [NUM_OUT_BITS-1:0] num_out
);

	wire [NUM_OUT_BITS-1:0] _ext_num;
	wire [NUM_OUT_BITS-1:0] _ext_mult;

	assign _ext_num = {{NUM_OUT_BITS-NUM_IN_BITS{num_in[NUM_IN_BITS-1]}}, num_in[NUM_IN_BITS-1:0]};
	assign _ext_mult = {{NUM_OUT_BITS-MULT_BITS{mult[MULT_BITS-1]}}, mult[MULT_BITS-1:0]};
	assign num_out = _ext_num * _ext_mult;

endmodule : Multiplier
