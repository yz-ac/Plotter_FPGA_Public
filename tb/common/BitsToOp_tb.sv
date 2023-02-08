`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::Op_st;

`define LOG() \
		`FWRITE(("time: %t, cmd: %d, arg_1: %d, arg_2: %d, arg_3: %d, arg_4: %d, flags: %d, op_bits: %d", $time, op.cmd, op.arg_1, op.arg_2, op.arg_3, op.arg_4, op.flags, op_bits))

module BitsToOp_tb;
	int fd;

	reg [`OP_BITS-1:0] op_bits;
	Op_st op;

	BitsToOp UUT (
		.op_bits(op_bits),
		.op(op)
	);

	initial begin
		`FOPEN("tests/tests/BitsToOp_tb.txt")

		op_bits = 'h0000100200000000;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op_bits = 'h0200300400500601;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : BitsToOp_tb
