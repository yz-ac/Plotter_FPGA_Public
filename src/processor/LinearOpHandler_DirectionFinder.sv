`include "common/common.svh"

import Position_PKG::PosDirection_t;
import Position_PKG::POS_DIR_UP;
import Position_PKG::POS_DIR_DOWN;
import Position_PKG::POS_DIR_LEFT;
import Position_PKG::POS_DIR_RIGHT;

/**
* Calculates the direction of the next step in linear movement.
*
* :param NUM_BITS: Field width of numbers.
* :input start_x: Start X coordinate.
* :input start_y: Start Y coordinate.
* :input cur_x: Current X coordinate.
* :input cur_y: Current Y coordinate.
* :input end_x: End X coordinate.
* :input end_y: End Y coordinate.
* :output dir: Direction of next movement.
*/
module LinearOpHandler_DirectionFinder #(
	parameter NUM_BITS = `BYTE_BITS
)
(
	input logic [NUM_BITS-1:0] start_x,
	input logic [NUM_BITS-1:0] start_y,
	input logic [NUM_BITS-1:0] cur_x,
	input logic [NUM_BITS-1:0] cur_y,
	input logic [NUM_BITS-1:0] end_x,
	input logic [NUM_BITS-1:0] end_y,

	output PosDirection_t dir
);

	localparam EXT_BITS = 2 * NUM_BITS + 1;

	wire [EXT_BITS-1:0] _ext_start_x;
	wire [EXT_BITS-1:0] _ext_start_y;
	wire [EXT_BITS-1:0] _ext_cur_x;
	wire [EXT_BITS-1:0] _ext_cur_y;
	wire [EXT_BITS-1:0] _ext_end_x;
	wire [EXT_BITS-1:0] _ext_end_y;

	wire [EXT_BITS-1:0] _dx;
	wire [EXT_BITS-1:0] _dy;

	wire [EXT_BITS-1:0] _lhs;
	wire [EXT_BITS-1:0] _rhs;
	wire [EXT_BITS-2:0] _abs_lhs;
	wire [EXT_BITS-2:0] _abs_rhs;

	Abs #(
		.NUM_BITS(EXT_BITS)
	) _find_abs_lhs (
		.num(_lhs),
		.out(_abs_lhs)
	);

	Abs #(
		.NUM_BITS(EXT_BITS)
	) _find_abs_rhs (
		.num(_rhs),
		.out(_abs_rhs)
	);

	assign _ext_start_x = {{EXT_BITS-NUM_BITS{start_x[NUM_BITS-1]}}, start_x[NUM_BITS-1:0]};
	assign _ext_start_y = {{EXT_BITS-NUM_BITS{start_y[NUM_BITS-1]}}, start_y[NUM_BITS-1:0]};
	assign _ext_cur_x = {{EXT_BITS-NUM_BITS{cur_x[NUM_BITS-1]}}, cur_x[NUM_BITS-1:0]};
	assign _ext_cur_y = {{EXT_BITS-NUM_BITS{cur_y[NUM_BITS-1]}}, cur_y[NUM_BITS-1:0]};
	assign _ext_end_x = {{EXT_BITS-NUM_BITS{end_x[NUM_BITS-1]}}, end_x[NUM_BITS-1:0]};
	assign _ext_end_y = {{EXT_BITS-NUM_BITS{end_y[NUM_BITS-1]}}, end_y[NUM_BITS-1:0]};

	assign _dx = _ext_end_x - _ext_start_x;
	assign _dy = _ext_end_y - _ext_start_y;

	// Linear equation of the form: (x1-x0)(y-y0)=(y1-y0)(x-x0)
	assign _lhs = _dx * (_ext_cur_y - _ext_start_y);
	assign _rhs = _dy * (_ext_cur_x - _ext_start_x);

	always_comb begin
		if (~|_dx) begin
			dir = POS_DIR_UP;
			if (_dy[EXT_BITS-1]) begin
				dir = POS_DIR_DOWN;
			end
		end
		else if (~|_dy) begin
			dir = POS_DIR_RIGHT;
			if (_dx[EXT_BITS-1]) begin
				dir = POS_DIR_LEFT;
			end
		end
		else begin
			if ((!_dx[EXT_BITS-1]) & (!_dy[EXT_BITS-1])) begin
				dir = POS_DIR_UP;
				if (_abs_lhs > _abs_rhs) begin
					dir = POS_DIR_RIGHT;
				end
			end
			else if ((!_dx[EXT_BITS-1]) & (_dy[EXT_BITS-1])) begin
				dir = POS_DIR_RIGHT;
				if (_abs_lhs < _abs_rhs) begin
					dir = POS_DIR_DOWN;
				end
			end
			else if ((_dx[EXT_BITS-1]) & (_dy[EXT_BITS-1])) begin
				dir = POS_DIR_DOWN;
				if (_abs_lhs > _abs_rhs) begin
					dir = POS_DIR_LEFT;
				end
			end
			else begin
				dir = POS_DIR_LEFT;
				if (_abs_lhs < _abs_rhs) begin
					dir = POS_DIR_UP;
				end
			end
		end
	end // always_comb

endmodule : LinearOpHandler_DirectionFinder
