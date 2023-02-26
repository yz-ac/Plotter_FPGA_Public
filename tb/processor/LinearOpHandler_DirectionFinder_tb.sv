`include "tb/simulation.svh"
`include "common/common.svh"

import Position_PKG::PosDirection_t;

`define LOG() \
`FWRITE(("time: %t, start: (%d, %d), cur: (%d, %d), end: (%d, %d), dir: %d", $time, start_x, start_y, cur_x, cur_y, end_x, end_y, dir))

module LinearOpHandler_DirectionFinder_tb;
	int fd;

	localparam NUM_BITS = `BYTE_BITS;

	reg [NUM_BITS-1:0] start_x;
	reg [NUM_BITS-1:0] start_y;
	reg [NUM_BITS-1:0] cur_x;
	reg [NUM_BITS-1:0] cur_y;
	reg [NUM_BITS-1:0] end_x;
	reg [NUM_BITS-1:0] end_y;
	PosDirection_t dir;

	LinearOpHandler_DirectionFinder #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.start_x(start_x),
		.start_y(start_y),
		.cur_x(cur_x),
		.cur_y(cur_y),
		.end_x(end_x),
		.end_y(end_y),
		.dir(dir)
	);

	initial begin
		`FOPEN("tests/tests/LinearOpHandler_DirectionFinder_tb.txt")

		start_x = 0;
		start_y = 0;
		cur_x = 0;
		cur_y = 0;
		end_x = 0;
		end_y = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 1;
		start_y = 1;
		cur_x = 7;
		cur_y = 6;
		end_x = 11;
		end_y = 11;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 1;
		start_y = 1;
		cur_x = 6;
		cur_y = 7;
		end_x = 11;
		end_y = 11;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 1;
		start_y = 11;
		cur_x = 5;
		cur_y = 6;
		end_x = 11;
		end_y = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 1;
		start_y = 11;
		cur_x = 6;
		cur_y = 7;
		end_x = 11;
		end_y = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 11;
		start_y = 11;
		cur_x = 7;
		cur_y = 6;
		end_x = 1;
		end_y = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 11;
		start_y = 11;
		cur_x = 6;
		cur_y = 7;
		end_x = 1;
		end_y = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 11;
		start_y = 1;
		cur_x = 5;
		cur_y = 6;
		end_x = 1;
		end_y = 11;
		#(`CLOCK_PERIOD * 2);
		`LOG

		start_x = 11;
		start_y = 1;
		cur_x = 6;
		cur_y = 7;
		end_x = 1;
		end_y = 11;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : LinearOpHandler_DirectionFinder_tb
