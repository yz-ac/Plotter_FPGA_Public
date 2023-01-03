`include "tb/simulation.svh"
`include "processor/processor.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

module PositionKeeper_tb;

	wire clk;
	reg reset;
	Op_st op;

	PositionUpdate_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) update_intf();

	wire [`POS_X_BITS-1:0] cur_x;
	wire [`POS_Y_BITS-1:0] cur_y;
	wire is_absolute;

	SimClock sim_clk (
		.out(clk)
	);

	PositionKeeper UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.update_intf(update_intf.slave),
		.cur_x(cur_x),
		.cur_y(cur_y),
		.is_absolute(is_absolute)
	);

	initial begin
		reset = 1;
		op = {OP_CMD_G01, 0, 0, 0, 0, 0};
		update_intf.new_x = 3;
		update_intf.new_y = -2;
		update_intf.update = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G90;
		#(`CLOCK_PERIOD * 2);

		update_intf.update = 1;
		#(`CLOCK_PERIOD * 2);

		update_intf.update = 0;
		op.cmd = OP_CMD_G91;
		#(`CLOCK_PERIOD * 2);

		$stop;
	end

endmodule : PositionKeeper_tb
