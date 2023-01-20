`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, r: %d, is_cw: %d, start: (%d, %d), end: (%d, %d), num_steps: %d", $time, r, is_cw, start_x, start_y, end_x, end_y, num_steps))

module CircularOpHandler_NumStepsCalculator_tb;
	int fd;

	localparam NUM_BITS = `BYTE_BITS;
	localparam STEP_BITS = NUM_BITS + 3;

	reg is_cw;
	reg [NUM_BITS-1:0] start_x;
	reg [NUM_BITS-1:0] start_y;
	reg [NUM_BITS-1:0] end_x;
	reg [NUM_BITS-1:0] end_y;
	reg [NUM_BITS-1:0] r;
	reg precise_crossing_axes;
	reg is_full_circle;
	wire [STEP_BITS-1:0] num_steps;

	CircularOpHandler_NumStepsCalculator #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.is_cw(is_cw),
		.start_x(start_x),
		.start_y(start_y),
		.end_x(end_x),
		.end_y(end_y),
		.r(r),
		.precise_crossing_axes(precise_crossing_axes),
		.is_full_circle(is_full_circle),
		.num_steps(num_steps)
	);

	initial begin
		`FOPEN("tests/tests/CircularOpHandler_NumStepsCalculator_tb.txt")

		r = 2;
		is_cw = 0;
		precise_crossing_axes = 1;
		is_full_circle = 0;

		start_x = 2;
		start_y = 0;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = -2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		is_full_circle = 1;
		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		is_full_circle = 0;
		is_cw = 1;

		start_x = 2;
		start_y = 0;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = -2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		is_full_circle = 1;
		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : CircularOpHandler_NumStepsCalculator_tb
