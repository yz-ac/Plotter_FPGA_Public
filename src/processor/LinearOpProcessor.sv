`include "../common/common.svh"
`include "../common/opcode.svh"

module LinearOpProcessor #(
	OP_BITS = `OP_BITS,
	ARG_BITS = `ARG_BITS,
	FLAG_BITS = `FLAG_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	// TODO: done from child, trigger from parent, opcode inputs
);

endmodule : LinearOpProcessor
