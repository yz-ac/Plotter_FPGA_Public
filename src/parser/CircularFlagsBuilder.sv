`include "common/common.svh"

import Position_PKG::PosQuadrant_t;
import Position_PKG::POS_QUADRANT_1;
import Position_PKG::POS_QUADRANT_2;
import Position_PKG::POS_QUADRANT_3;
import Position_PKG::POS_QUADRANT_4;

/**
* Calculates flags for circular opcodes.
*
* :iface pos_intf: Interface for getting precise position.
* :input x: Command 'x' argument.
* :input y: Command 'y' argument.
* :input i: Command 'i' argument.
* :input j: Command 'j' argument.
* :output flags: Flags for opcode.
*/
module CircularFlagsBuilder (
	PositionState_IF pos_intf,
	input logic [pos_intf.POS_X_BITS-1:0] x,
	input logic [pos_intf.POS_Y_BITS-1:0] y,
	input logic [pos_intf.POS_X_BITS-1:0] i,
	input logic [pos_intf.POS_Y_BITS-1:0] j,

	output logic [`OP_FLAGS_BITS-1:0] flags
);

	localparam NUM_BITS = pos_intf.POS_X_BITS + pos_intf.POS_Y_BITS - 1;

	wire [NUM_BITS-1:0] _ext_cur_x;
	wire [NUM_BITS-1:0] _ext_cur_y;
	wire [NUM_BITS-1:0] _ext_x;
	wire [NUM_BITS-1:0] _ext_y;
	wire [NUM_BITS-1:0] _ext_i;
	wire [NUM_BITS-1:0] _ext_j;

	wire [NUM_BITS-1:0] _center_x;
	wire [NUM_BITS-1:0] _center_y;

	wire [NUM_BITS-1:0] _start_x;
	wire [NUM_BITS-1:0] _start_y;
	wire [NUM_BITS-1:0] _end_x;
	wire [NUM_BITS-1:0] _end_y;

	PosQuadrant_t _start_quadrant;
	PosQuadrant_t _end_quadrant;

	wire [NUM_BITS-2:0] _abs_start_x;
	wire [NUM_BITS-2:0] _abs_start_y;
	wire [NUM_BITS-2:0] _abs_end_x;
	wire [NUM_BITS-2:0] _abs_end_y;

	wire _is_full_circle;
	reg _is_crossing_axes;

	wire [`OP_FLAGS_BITS-1:0] _flags;

	QuadrantFinder #(
		.NUM_BITS(NUM_BITS)
	) _find_start_quadrant (
		.relative_x(_start_x),
		.relative_y(_start_y),
		.quadrant(_start_quadrant)
	);

	QuadrantFinder #(
		.NUM_BITS(NUM_BITS)
	) _find_end_quadrant (
		.relative_x(_end_x),
		.relative_y(_end_y),
		.quadrant(_end_quadrant)
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_start_x (
		.num(_start_x),
		.out(_abs_start_x)
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_start_y (
		.num(_start_y),
		.out(_abs_start_y)
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_end_x (
		.num(_end_x),
		.out(_abs_end_x)
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_end_y (
		.num(_end_y),
		.out(_abs_end_y)
	);

	assign _ext_cur_x = {{NUM_BITS-pos_intf.POS_X_BITS{pos_intf.cur_x[pos_intf.POS_X_BITS-1]}}, pos_intf.cur_x[pos_intf.POS_X_BITS-1:0]};
	assign _ext_cur_y = {{NUM_BITS-pos_intf.POS_Y_BITS{pos_intf.cur_y[pos_intf.POS_Y_BITS-1]}}, pos_intf.cur_y[pos_intf.POS_Y_BITS-1:0]};

	assign _ext_x = {{NUM_BITS-pos_intf.POS_X_BITS{x[pos_intf.POS_X_BITS-1]}}, x[pos_intf.POS_X_BITS-1:0]};
	assign _ext_y = {{NUM_BITS-pos_intf.POS_Y_BITS{y[pos_intf.POS_Y_BITS-1]}}, y[pos_intf.POS_Y_BITS-1:0]};
	assign _ext_i = {{NUM_BITS-pos_intf.POS_X_BITS{i[pos_intf.POS_X_BITS-1]}}, i[pos_intf.POS_X_BITS-1:0]};
	assign _ext_j = {{NUM_BITS-pos_intf.POS_Y_BITS{j[pos_intf.POS_Y_BITS-1]}}, j[pos_intf.POS_Y_BITS-1:0]};

	assign _center_x = _ext_cur_x + _ext_i;
	assign _center_y = _ext_cur_y + _ext_j;

	assign _start_x = _ext_cur_x - _center_x;
	assign _start_y = _ext_cur_y - _center_y;
	assign _end_x = (pos_intf.is_absolute) ? (_ext_x - _center_x) : (_start_x + _ext_x - _center_x);
	assign _end_y = (pos_intf.is_absolute) ? (_ext_y - _center_y) : (_start_y + _ext_y - _center_y);

	// (start == end) and (r != 0)
	assign _is_full_circle = ((_start_x == _end_x) & (_start_y == _end_y) & ((|_ext_i) | (|_ext_j))) ? 1 : 0;

	assign flags = _flags;
	assign _flags[`OP_FLAGS_AXES_CROSS_BIT] = _is_crossing_axes;
	assign _flags[`OP_FLAGS_FULL_CIRCLE_BIT] = _is_full_circle;
	assign _flags[`OP_FLAGS_BITS-1:2] = 0;

	always_comb begin : __crossing_axes_check
		_is_crossing_axes = 0;
		if (_start_quadrant == _end_quadrant) begin
			case (_start_quadrant)
			POS_QUADRANT_1: begin
				if ((_abs_end_x > _abs_start_x) | (_abs_end_y < _abs_start_y)) begin
					_is_crossing_axes = 1;
				end
			end
			POS_QUADRANT_2: begin
				if ((_abs_end_x < _abs_start_x) | (_abs_end_y > _abs_start_y)) begin
					_is_crossing_axes = 1;
				end
			end
			POS_QUADRANT_3: begin
				if ((_abs_end_x > _abs_start_x) | (_abs_end_y < _abs_start_y)) begin
					_is_crossing_axes = 1;
				end
			end
			default: begin
				if ((_abs_end_x < _abs_start_x) | (_abs_end_y > _abs_start_y)) begin
					_is_crossing_axes = 1;
				end
			end
			endcase

			if ((_abs_end_x == _abs_start_x) & (_abs_end_y == _abs_start_y) & _is_full_circle) begin
				_is_crossing_axes = 1;
			end
		end
		else begin
			_is_crossing_axes = 1;
		end
	end : __crossing_axes_check

endmodule : CircularFlagsBuilder
