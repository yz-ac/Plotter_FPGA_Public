`include "common/common.svh"

import Position_PKG::PosQuadrant_t;
import Position_PKG::POS_QUADRANT_1;
import Position_PKG::POS_QUADRANT_2;
import Position_PKG::POS_QUADRANT_3;
import Position_PKG::POS_QUADRANT_4;

/**
* Finds the quadrant of the given x, y coordinates.
*
* :param NUM_BITS: Numbers fields width.
* :input relative_x: X relative to circle center.
* :input relative_y: Y relative to circle center.
* :output quadrant: The quadrant containing the (x,y) coordinate.
*/
module CircularOpHandler_QuadrantFinder #(
	parameter NUM_BITS = `BYTE_BITS
)
(
	input logic [NUM_BITS-1:0] relative_x,
	input logic [NUM_BITS-1:0] relative_y,
	output PosQuadrant_t quadrant
);

	wire _x_negative;
	wire _y_negative;

	assign _x_negative = relative_x[NUM_BITS-1];
	assign _y_negative = relative_y[NUM_BITS-1];

	always_comb begin
		if (!_x_negative & !_y_negative) begin
			quadrant = POS_QUADRANT_1;
		end
		else if (_x_negative & !_y_negative) begin
			quadrant = POS_QUADRANT_2;
		end
		else if (_x_negative & _y_negative) begin
			quadrant = POS_QUADRANT_3;
		end
		else begin
			quadrant = POS_QUADRANT_4;
		end
	end // always_comb

endmodule : CircularOpHandler_QuadrantFinder
