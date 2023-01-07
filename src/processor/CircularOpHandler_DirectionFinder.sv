`include "common/common.svh"

import Position_PKG::PosQuadrant_t;
import Position_PKG::POS_QUADRANT_1;
import Position_PKG::POS_QUADRANT_2;
import Position_PKG::POS_QUADRANT_3;
import Position_PKG::POS_QUADRANT_4;

import Position_PKG::PosDirection_t;
import Position_PKG::POS_DIR_UP;
import Position_PKG::POS_DIR_DOWN;
import Position_PKG::POS_DIR_LEFT;
import Position_PKG::POS_DIR_RIGHT;

/**
* Calculates the direction of the next step in circular movement.
*
* :param NUM_BITS: Field width of numbers.
* :input is_cw: Is clockwise rotation.
* :input quadrant: Quadrant of current position.
* :input r_squared: Squared radius of wanted circle.
* :input cur_r_squared: Squared radius of actual position.
* :output dir: Direction of next movement.
*/
module CircularOpHandler_DirectionFinder #(
	parameter NUM_BITS = `BYTE_BITS
)
(
	input logic is_cw,
	input PosQuadrant_t quadrant,
	input [NUM_BITS-1:0] r_squared,
	input [NUM_BITS-1:0] cur_r_squared,

	output PosDirection_t dir
);

	always_comb begin
		if (is_cw) begin
			case (quadrant)
			POS_QUADRANT_1: begin
				dir = POS_DIR_RIGHT;
				if (cur_r_squared >= r_squared) begin
					dir = POS_DIR_DOWN;
				end
			end
			POS_QUADRANT_2: begin
				dir = POS_DIR_RIGHT;
				if (cur_r_squared < r_squared) begin
					dir = POS_DIR_UP;
				end
			end
			POS_QUADRANT_3: begin
				dir = POS_DIR_LEFT;
				if (cur_r_squared >= r_squared) begin
					dir = POS_DIR_UP;
				end
			end
			default: begin
				dir = POS_DIR_LEFT;
				if (cur_r_squared < r_squared) begin
					dir = POS_DIR_DOWN;
				end
			end
			endcase
		end
		else begin
			case (quadrant)
			POS_QUADRANT_1: begin
				dir = POS_DIR_UP;
				if (cur_r_squared >= r_squared) begin
					dir = POS_DIR_LEFT;
				end
			end
			POS_QUADRANT_2: begin
				dir = POS_DIR_DOWN;
				if (cur_r_squared < r_squared) begin
					dir = POS_DIR_LEFT;
				end
			end
			POS_QUADRANT_3: begin
				dir = POS_DIR_DOWN;
				if (cur_r_squared >= r_squared) begin
					dir = POS_DIR_RIGHT;
				end
			end
			default: begin
				dir = POS_DIR_UP;
				if (cur_r_squared < r_squared) begin
					dir = POS_DIR_RIGHT;
				end
			end
			endcase
		end
	end // always_comb

endmodule : CircularOpHandler_DirectionFinder
