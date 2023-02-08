`include "common/common.svh"

import Op_PKG::Op_st;

/**
* Converts an opcode struct to opcode bits.
*
* :input op: Opcode struct.
* :output op_bits: Opcode bits.
*/
module OpToBits (
	input Op_st op,
	output logic [`OP_BITS-1:0] op_bits
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

	assign op_bits[CMD_MSB:CMD_LSB] = op.cmd;
	assign op_bits[ARG_1_MSB:ARG_1_LSB] = op.arg_1;
	assign op_bits[ARG_2_MSB:ARG_2_LSB] = op.arg_2;
	assign op_bits[ARG_3_MSB:ARG_3_LSB] = op.arg_3;
	assign op_bits[ARG_4_MSB:ARG_4_LSB] = op.arg_4;
	assign op_bits[FLAGS_MSB:FLAGS_LSB] = op.flags;

endmodule : OpToBits
