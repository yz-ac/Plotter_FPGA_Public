`ifndef __POSITION_SVH__
`define __POSITION_SVH__

`include "common/op.svh"

`define POS_X_BITS (`OP_ARG_1_BITS)
`define POS_Y_BITS (`OP_ARG_2_BITS)

`define PRECISE_POS_X_BITS (`POS_X_BITS + 14)
`define PRECISE_POS_Y_BITS (`POS_Y_BITS + 14)

`endif // __POSITION_SVH__
