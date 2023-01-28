`include "common/common.svh"

import Position_PKG::PosQuadrant_t;
import Position_PKG::POS_QUADRANT_1;
import Position_PKG::POS_QUADRANT_2;
import Position_PKG::POS_QUADRANT_3;
import Position_PKG::POS_QUADRANT_4;

/**
* Calculates the number of steps for the requested rotation.
*
* :param NUM_BITS: Field width of numbers.
* :input is_cw: Is clockwise rotation.
* :input start_x: Start X coordinate.
* :input start_y: Start Y coordinate.
* :input end_x: End X coordinate.
* :input end_y: End Y coordinate.
* :input r: Radius of circular path.
* :input precise_crossing_axes: Is crossing axes calculated with precise (non-integer) values.
* :input is_full_circle: Is the command drawing a full circle.
* :output num_steps: Number of steps in the path.
*/
module CircularOpHandler_NumStepsCalculator #(
	parameter NUM_BITS = `BYTE_BITS,
	localparam STEP_BITS = NUM_BITS + 3 // Max is r * 8
)
(
	input logic is_cw,
	input logic [NUM_BITS-1:0] start_x,
	input logic [NUM_BITS-1:0] start_y,
	input logic [NUM_BITS-1:0] end_x,
	input logic [NUM_BITS-1:0] end_y,
	input logic [NUM_BITS-1:0] r,
	input logic precise_crossing_axes,
	input logic is_full_circle,

	output logic [STEP_BITS-1:0] num_steps
);

	wire [STEP_BITS-1:0] _ext_start_x;
	wire [STEP_BITS-1:0] _ext_start_y;
	wire [STEP_BITS-1:0] _ext_end_x;
	wire [STEP_BITS-1:0] _ext_end_y;
	wire [STEP_BITS-1:0] _ext_r;

	wire [STEP_BITS-1:0] _abs_start_x;
	wire [STEP_BITS-1:0] _abs_start_y;
	wire [STEP_BITS-1:0] _abs_end_x;
	wire [STEP_BITS-1:0] _abs_end_y;
	PosQuadrant_t _start_quadrant;
	PosQuadrant_t _end_quadrant;

	reg _is_crossing_axes;
	reg _approx_crossing_axes;
	reg [STEP_BITS-1:0] _full_quadrant_steps;
	reg [STEP_BITS-1:0] _start_to_axis_steps;
	reg [STEP_BITS-1:0] _axis_to_end_steps;

	wire [NUM_BITS-1:0] _dx;
	wire [NUM_BITS-1:0] _dy;
	wire [STEP_BITS-1:0] _abs_dx;
	wire [STEP_BITS-1:0] _abs_dy;
	wire [STEP_BITS-1:0] _same_quadrant_steps; // simple case (no axis crossing)

	wire [STEP_BITS-1:0] _steps_ccw;
	wire [STEP_BITS-1:0] _steps_cw;

	wire _is_zero_steps;

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_start_x (
		.num(start_x),
		.out(_abs_start_x[NUM_BITS-2:0])
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_start_y (
		.num(start_y),
		.out(_abs_start_y[NUM_BITS-2:0])
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_end_x (
		.num(end_x),
		.out(_abs_end_x[NUM_BITS-2:0])
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_end_y (
		.num(end_y),
		.out(_abs_end_y[NUM_BITS-2:0])
	);

	QuadrantFinder #(
		.NUM_BITS(NUM_BITS)
	) _find_start_qudrant (
		.relative_x(start_x),
		.relative_y(start_y),
		.quadrant(_start_quadrant)
	);

	QuadrantFinder #(
		.NUM_BITS(NUM_BITS)
	) _find_end_quadrant (
		.relative_x(end_x),
		.relative_y(end_y),
		.quadrant(_end_quadrant)
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_dx (
		.num(_dx),
		.out(_abs_dx[NUM_BITS-2:0])
	);

	Abs #(
		.NUM_BITS(NUM_BITS)
	) _find_abs_dy (
		.num(_dy),
		.out(_abs_dy[NUM_BITS-2:0])
	);

	assign _ext_start_x = {{STEP_BITS-NUM_BITS{start_x[NUM_BITS-1]}}, start_x[NUM_BITS-1:0]};
	assign _ext_start_y = {{STEP_BITS-NUM_BITS{start_y[NUM_BITS-1]}}, start_y[NUM_BITS-1:0]};
	assign _ext_end_x = {{STEP_BITS-NUM_BITS{end_x[NUM_BITS-1]}}, end_x[NUM_BITS-1:0]};
	assign _ext_end_y = {{STEP_BITS-NUM_BITS{end_y[NUM_BITS-1]}}, end_y[NUM_BITS-1:0]};
	assign _ext_r = {{STEP_BITS-NUM_BITS{r[NUM_BITS-1]}}, r[NUM_BITS-1:0]};

	assign _abs_start_x[STEP_BITS-1:NUM_BITS-1] = 0;
	assign _abs_start_y[STEP_BITS-1:NUM_BITS-1] = 0;
	assign _abs_end_x[STEP_BITS-1:NUM_BITS-1] = 0;
	assign _abs_end_y[STEP_BITS-1:NUM_BITS-1] = 0;

	assign _dx = end_x - start_x;
	assign _dy = end_y - start_y;
	assign _abs_dx[STEP_BITS-1:NUM_BITS-1] = 0;
	assign _abs_dy[STEP_BITS-1:NUM_BITS-1] = 0;
	assign _same_quadrant_steps = _abs_dx + _abs_dy;

	assign _is_crossing_axes = precise_crossing_axes & _approx_crossing_axes;
	assign _is_zero_steps = (~|_steps_ccw) ? 1 : 0;
	assign _steps_ccw = (_is_crossing_axes) ? (_full_quadrant_steps + _start_to_axis_steps + _axis_to_end_steps) : (_same_quadrant_steps);
	assign _steps_cw = ((start_x == end_x) & (start_y == end_y) & (is_full_circle | _is_zero_steps)) ? (_steps_ccw) : (8 * _ext_r - _steps_ccw);
	assign num_steps = (is_cw) ? (_steps_cw) : (_steps_ccw);

	// Calculate if crossing axes in path.
	always_comb begin : __crossing_axes_check
		_approx_crossing_axes = 0;
		if (_start_quadrant == _end_quadrant) begin
			case (_start_quadrant)
			POS_QUADRANT_1: begin
				if ((_abs_end_x > _abs_start_x) | (_abs_end_y < _abs_start_y)) begin
					_approx_crossing_axes = 1;
				end
			end
			POS_QUADRANT_2: begin
				if ((_abs_end_x < _abs_start_x) | (_abs_end_y > _abs_start_y)) begin
					_approx_crossing_axes = 1;
				end
			end
			POS_QUADRANT_3: begin
				if ((_abs_end_x > _abs_start_x) | (_abs_end_y < _abs_start_y)) begin
					_approx_crossing_axes = 1;
				end
			end
			default: begin
				if ((_abs_end_x < _abs_start_x) | (_abs_end_y > _abs_start_y)) begin
					_approx_crossing_axes = 1;
				end
			end
			endcase

			if ((_abs_end_x == _abs_start_x) & (_abs_end_y == _abs_start_y) & is_full_circle) begin
				_approx_crossing_axes = 1;
			end
		end
		else begin
			_approx_crossing_axes = 1;
		end
	end : __crossing_axes_check

	// Calculate number of steps in quadrants that are passed fully (from axis to axis).
	always_comb begin : __calc_full_quadrant_steps
		_full_quadrant_steps = (_end_quadrant - _start_quadrant - 1) * 2 * _ext_r;
		if (_end_quadrant <= _start_quadrant) begin
			_full_quadrant_steps = (_end_quadrant + 4 - _start_quadrant - 1) * 2 * _ext_r;
		end

		if (!_is_crossing_axes) begin
			_full_quadrant_steps = 0;
		end
	end : __calc_full_quadrant_steps

	always_comb begin : __calc_start_to_axis_steps
		case (_start_quadrant)
		POS_QUADRANT_1: begin
			_start_to_axis_steps = _abs_start_x - _abs_start_y + _ext_r;
		end
		POS_QUADRANT_2: begin
			_start_to_axis_steps = _ext_r - _abs_start_x + _abs_start_y;
		end
		POS_QUADRANT_3: begin
			_start_to_axis_steps = _abs_start_x - _abs_start_y + _ext_r;
		end
		default: begin
			_start_to_axis_steps = _ext_r - _abs_start_x + _abs_start_y;
		end
		endcase
	end : __calc_start_to_axis_steps

	always_comb begin : __calc_axis_to_end_steps
		case (_end_quadrant)
		POS_QUADRANT_1: begin
			_axis_to_end_steps = _ext_r - _abs_end_x + _abs_end_y;
		end
		POS_QUADRANT_2: begin
			_axis_to_end_steps = _abs_end_x - _abs_end_y + _ext_r;
		end
		POS_QUADRANT_3: begin
			_axis_to_end_steps = _ext_r - _abs_end_x + _abs_end_y;
		end
		default: begin
			_axis_to_end_steps = _abs_end_x - _abs_end_y + _ext_r;
		end
		endcase
	end : __calc_axis_to_end_steps

endmodule : CircularOpHandler_NumStepsCalculator
