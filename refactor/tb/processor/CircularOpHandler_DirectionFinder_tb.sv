`include "tb/simulation.svh"
`include "common/common.svh"

import Position_PKG::PosQuadrant_t;
import Position_PKG::POS_QUADRANT_1;
import Position_PKG::POS_QUADRANT_2;
import Position_PKG::POS_QUADRANT_3;
import Position_PKG::POS_QUADRANT_4;
import Position_PKG::PosDirection_t;

module CircularOpHandler_DirectionFinder_tb;

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
		r_squared = 10;
		is_cw = 0;
		quadrant = POS_QUADRANT_1;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		quadrant = POS_QUADRANT_2;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		quadrant = POS_QUADRANT_3;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		quadrant = POS_QUADRANT_4;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		is_cw = 1;
		quadrant = POS_QUADRANT_1;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		quadrant = POS_QUADRANT_2;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		quadrant = POS_QUADRANT_3;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		quadrant = POS_QUADRANT_4;
		cur_r_squared = 15;
		#(`CLOCK_PERIOD * 2);

		cur_r_squared = 5;
		#(`CLOCK_PERIOD * 2);

		$stop;
	end // initial

endmodule : CircularOpHandler_DirectionFinder_tb
