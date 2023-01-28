`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, cur_x: %d, cur_y: %d, x: %d, y: %d, i: %d, j: %d, flags: %d", $time, pos_intf.master.cur_x, pos_intf.master.cur_y, x, y, i, j, flags))

module CircularFlagsBuilder_tb;
	int fd;

	PositionState_IF #(
		.POS_X_BITS(`PRECISE_POS_X_BITS),
		.POS_Y_BITS(`PRECISE_POS_Y_BITS)
	) pos_intf ();
	reg [`PRECISE_POS_X_BITS-1:0] x;
	reg [`PRECISE_POS_Y_BITS-1:0] y;
	reg [`PRECISE_POS_X_BITS-1:0] i;
	reg [`PRECISE_POS_Y_BITS-1:0] j;
	wire [`OP_FLAGS_BITS-1:0] flags;

	CircularFlagsBuilder UUT (
		.pos_intf(pos_intf.slave),
		.x(x),
		.y(y),
		.i(i),
		.j(j),
		.flags(flags)
	);

	initial begin
		`FOPEN("tests/tests/CircularFlagsBuilder_tb.txt")

		pos_intf.master.cur_x = 0;
		pos_intf.master.cur_y = 0;
		pos_intf.master.is_absolute = 1;
		x = 0;
		y = 0;
		i = 0;
		j = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		i = 1;
		j = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		pos_intf.master.cur_x = 2;
		x = -1;
		y = 1;
		i = -2;
		j = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		pos_intf.master.cur_x = 2;
		pos_intf.master.cur_y = 2;
		x = 1;
		y = 3;
		i = -2;
		j = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : CircularFlagsBuilder_tb
