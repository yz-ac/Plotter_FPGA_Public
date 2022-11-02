`ifndef __OPCODE_SVH__
`define __OPCODE_SVH__

// Opcode format
`define OP_BITS (8)
`define ARG_BITS (12)
`define FLAG_BITS (8)

package Opcode_p;
	typedef struct {
		bit [`OP_BITS-1:0] op;
		bit [`ARG_BITS-1:0] arg1;
		bit [`ARG_BITS-1:0] arg2;
		bit [`ARG_BITS-1:0] arg3;
		bit [`ARG_BITS-1:0] arg4;
		bit [`FLAG_BITS-1:0] flags;
	} Opcode_st;
endpackage : Opcode_p

`endif // __OPCODE_SVH__
