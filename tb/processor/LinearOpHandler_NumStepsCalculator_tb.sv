`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, start: (%d, %d), end: (%d, %d), steps: %d", $time, start_x, start_y, end_x, end_y, num_steps))

module LinearOpHandler_NumStepsCalculator_tb;
	int fd;

	localparam NUM_BITS = `BYTE_BITS;
	localparam STEP_BITS = NUM_BITS + 3;

	reg [NUM_BITS-1:0] start_x;
	reg [NUM_BITS-1:0] start_y;
	reg [NUM_BITS-1:0] end_x;
	reg [NUM_BITS-1:0] end_y;
	wire [STEP_BITS-1:0] num_steps;

	LinearOpHandler_NumStepsCalculator #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.start_x(start_x),
		.start_y(start_y),
		.end_x(end_x),
		.end_y(end_y),
		.num_steps(num_steps)
	);

	initial begin
		`FOPEN("tests/tests/LinearOpHandler_NumStepsCalculator_tb.txt")

		start_x = 0;
		start_y = 0;
		end_x = 0;
		end_y = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 2;
		start_y = -1;
		end_x = 4;
		end_y = -5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = -1;
		start_y = 3;
		end_x = -2;
		end_y = 6;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 1;
		start_y = 2;
		end_x = 2;
		end_y = 3;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = -1;
		start_y = -2;
		end_x = -3;
		end_y = -4;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : LinearOpHandler_NumStepsCalculator_tb
