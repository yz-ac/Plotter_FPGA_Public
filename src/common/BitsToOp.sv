`include "common/common.svh"

import Op_PKG::Op_st;

/**
* Converts opcode bits to an opcode struct.
*
* :input op_bits: Opcode bits.
* :output op: Opcode struct.
*/
module BitsToOp (
	input logic [`OP_BITS-1:0] op_bits,
	output Op_st op
);

	localparam FLAGS_LSB = 0;
	localparam FLAGS_MSB = FLAGS_LSB + `OP_FLAGS_BITS - 1;
	localparam ARG_4_LSB = FLAGS_MSB + 1;
	localparam ARG_4_MSB = ARG_4_LSB + `OP_ARG_4_BITS - 1;
	localparam ARG_3_LSB = ARG_4_MSB + 1;
	localparam ARG_3_MSB = ARG_3_LSB + `OP_ARG_3_BITS - 1;
	localparam ARG_2_LSB = ARG_3_MSB + 1;
	localparam ARG_2_MSB = ARG_2_LSB + `OP_ARG_2_BITS - 1;
	localparam ARG_1_LSB = ARG_2_MSB + 1;
	localparam ARG_1_MSB = ARG_1_LSB + `OP_ARG_1_BITS - 1;
	localparam CMD_LSB = ARG_1_MSB + 1;
	localparam CMD_MSB = CMD_LSB + `OP_CMD_BITS - 1;

	assign op.cmd = op_bits[CMD_MSB:CMD_LSB];
	assign op.arg_1 = op_bits[ARG_1_MSB:ARG_1_LSB];
	assign op.arg_2 = op_bits[ARG_2_MSB:ARG_2_LSB];
	assign op.arg_3 = op_bits[ARG_3_MSB:ARG_3_LSB];
	assign op.arg_4 = op_bits[ARG_4_MSB:ARG_4_LSB];
	assign op.flags = op_bits[FLAGS_MSB:FLAGS_LSB];

endmodule : BitsToOp
