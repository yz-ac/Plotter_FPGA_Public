`include "common/common.svh"

package Op_PKG;

	typedef struct {
		bit [`OP_CMD_BITS-1:0] cmd;
		bit [`OP_ARG_1_BITS-1:0] arg_1;
		bit [`OP_ARG_2_BITS-1:0] arg_2;
		bit [`OP_ARG_3_BITS-1:0] arg_3;
		bit [`OP_ARG_4_BITS-1:0] arg_4;
		bit [`OP_FLAGS_BITS-1:0] flags;
	} Op_st;

endpackage : Op_PKG
