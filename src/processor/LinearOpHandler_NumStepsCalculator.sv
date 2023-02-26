`include "common/common.svh"

/**
* Calculates the number of steps needed to draw a line.
*
* :param NUM_BITS: Field width of numbers.
* :input start_x: Start X coordinate.
* :input start_y: Start Y coordinate.
* :input end_x: End X coordinate.
* :input end_y: End Y coordinate.
* :output num_steps: Number of steps in the path.
*/
module LinearOpHandler_NumStepsCalculator #(
	parameter NUM_BITS = `BYTE_BITS,
	localparam STEP_BITS = NUM_BITS + 3 // Max is dx + dy
)
(
	input logic [NUM_BITS-1:0] start_x,
	input logic [NUM_BITS-1:0] start_y,
	input logic [NUM_BITS-1:0] end_x,
	input logic [NUM_BITS-1:0] end_y,

	output logic [STEP_BITS-1:0] num_steps
);

	wire [STEP_BITS-1:0] _ext_start_x;
	wire [STEP_BITS-1:0] _ext_start_y;
	wire [STEP_BITS-1:0] _ext_end_x;
	wire [STEP_BITS-1:0] _ext_end_y;
	
	wire [STEP_BITS-1:0] _dx;
	wire [STEP_BITS-1:0] _dy;
	wire [STEP_BITS-2:0] _abs_dx;
	wire [STEP_BITS-2:0] _abs_dy;

	Abs #(
		.NUM_BITS(STEP_BITS)
	) _find_abs_dx (
		.num(_dx),
		.out(_abs_dx)
	);

	Abs #(
		.NUM_BITS(STEP_BITS)
	) _find_abs_dy (
		.num(_dy),
		.out(_abs_dy)
	);

	assign _ext_start_x = {{STEP_BITS-NUM_BITS{start_x[NUM_BITS-1]}}, start_x[NUM_BITS-1:0]};
	assign _ext_start_y = {{STEP_BITS-NUM_BITS{start_y[NUM_BITS-1]}}, start_y[NUM_BITS-1:0]};
	assign _ext_end_x = {{STEP_BITS-NUM_BITS{end_x[NUM_BITS-1]}}, end_x[NUM_BITS-1:0]};
	assign _ext_end_y = {{STEP_BITS-NUM_BITS{end_y[NUM_BITS-1]}}, end_y[NUM_BITS-1:0]};

	assign _dx = _ext_end_x - _ext_start_x;
	assign _dy = _ext_end_y - _ext_start_y;

	assign num_steps = {1'b0, _abs_dx + _abs_dy};

endmodule : LinearOpHandler_NumStepsCalculator
