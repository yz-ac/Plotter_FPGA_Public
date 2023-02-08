`include "tb/simulation.svh"
`include "common/common.svh"

import Op_PKG::Op_st;

`define LOG() \
		`FWRITE(("time: %t, cmd: %d, arg_1: %d, arg_2: %d, arg_3: %d, arg_4: %d, flags: %d, op_bits: %d", $time, op.cmd, op.arg_1, op.arg_2, op.arg_3, op.arg_4, op.flags, op_bits))

module OpToBits_tb;
	int fd;

	Op_st op;
	wire [`OP_BITS-1:0] op_bits;

	OpToBits UUT (
		.op(op),
		.op_bits(op_bits)
	);

	initial begin
		`FOPEN("tests/tests/OpToBits_tb.txt")

		op = {0, 1, 2, 0, 0, 0};
		#(`CLOCK_PERIOD * 2);
		`LOG

		op = {2, 3, 4, 5, 6, 1};
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : OpToBits_tb
