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

	typedef enum {
		OP_CMD_G00 = 0,
		OP_CMD_G01 = 1,
		OP_CMD_G02 = 2,
		OP_CMD_G03 = 3,
		OP_CMD_G90 = 4,
		OP_CMD_G91 = 5
	} OpCmd_t;

endpackage : Op_PKG
