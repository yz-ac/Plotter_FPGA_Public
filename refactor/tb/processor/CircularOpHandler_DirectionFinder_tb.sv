`include "tb/simulation.svh"
`include "common/common.svh"

import Position_PKG::PosQuadrant_t;
import Position_PKG::POS_QUADRANT_1;
import Position_PKG::POS_QUADRANT_2;
import Position_PKG::POS_QUADRANT_3;
import Position_PKG::POS_QUADRANT_4;
import Position_PKG::PosDirection_t;

`define LOG() \
		`FWRITE(("time: %t, r2: %d, cur_r2: %d, quadrant: %d, dir: %d", $time, r_squared, cur_r_squared, quadrant, dir))

module CircularOpHandler_DirectionFinder_tb;
	int fd;

	localparam NUM_BITS = `BYTE_BITS;

	reg is_cw;
	PosQuadrant_t quadrant;
	reg [NUM_BITS-1:0] r_squared;
	reg [NUM_BITS-1:0] cur_r_squared;
	PosDirection_t dir;

	CircularOpHandler_DirectionFinder #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.is_cw(is_cw),
		.quadrant(quadrant),
		.r_squared(r_squared),
		.cur_r_squared(cur_r_squared),
		.dir(dir)
	);

	initial begin
		`FOPEN("tests/tests/CircularOpHandler_DirectionFinder_tb.txt")

		r_squared = 10;
		is_cw = 0;
		quadrant = POS_QUADRANT_1;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		quadrant = POS_QUADRANT_2;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		quadrant = POS_QUADRANT_3;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		quadrant = POS_QUADRANT_4;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		is_cw = 1;
		quadrant = POS_QUADRANT_1;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		quadrant = POS_QUADRANT_2;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		quadrant = POS_QUADRANT_3;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		quadrant = POS_QUADRANT_4;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);
		`LOG

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : CircularOpHandler_DirectionFinder_tb
