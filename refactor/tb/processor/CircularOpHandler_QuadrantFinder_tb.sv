`include "tb/simulation.svh"
`include "common/common.svh"

import Position_PKG::PosQuadrant_t;

module CircularOpHandler_QuadrantFinder_tb;

	localparam NUM_BITS = `BYTE_BITS;

	reg [NUM_BITS-1:0] rel_x;
	reg [NUM_BITS-1:0] rel_y;
	PosQuadrant_t quadrant;

	CircularOpHandler_QuadrantFinder #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.relative_x(rel_x),
		.relative_y(rel_y),
		.quadrant(quadrant)
	);

	initial begin
		rel_x = 0;
		rel_y = 0;
		#(`CLOCK_PERIOD * 2);

		rel_x = 1;
		rel_y = 2;
		#(`CLOCK_PERIOD * 2);

		rel_x = -4;
		rel_y = 2;
		#(`CLOCK_PERIOD * 2);

		rel_x = -5;
		rel_y = -4;
		#(`CLOCK_PERIOD * 2);

		rel_x = 2;
		rel_y = -2;
		#(`CLOCK_PERIOD * 2);

		$stop;
	end // initial

endmodule : CircularOpHandler_QuadrantFinder_tb
