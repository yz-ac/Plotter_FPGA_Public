`include "tb/simulation.svh"
`include "common/common.svh"

module CircularOpHandler_NumStepsCalculator_tb;

	localparam NUM_BITS = `BYTE_BITS;
	localparam STEP_BITS = NUM_BITS + 3;

	reg is_cw;
	reg [NUM_BITS-1:0] start_x;
	reg [NUM_BITS-1:0] start_y;
	reg [NUM_BITS-1:0] end_x;
	reg [NUM_BITS-1:0] end_y;
	reg [NUM_BITS-1:0] r;
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
		.num_steps(num_steps)
	);

	initial begin
		r = 2;
		is_cw = 0;

		start_x = 2;
		start_y = 0;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);

		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = -2;
		#(`CLOCK_PERIOD * 2);

		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);

		is_cw = 1;

		start_x = 2;
		start_y = 0;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);

		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = -2;
		#(`CLOCK_PERIOD * 2);

		start_x = 0;
		start_y = 2;
		end_x = 0;
		end_y = 2;
		#(`CLOCK_PERIOD * 2);

		$stop;
	end // initial

endmodule : CircularOpHandler_NumStepsCalculator_tb
