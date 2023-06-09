`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, gcode: %d, cmd: %d, is_valid: %d", $time, gcode, cmd, is_valid))

module GcodeToCmd_tb;
	int fd;

	localparam NUM_BITS = `BYTE_BITS;

	reg [NUM_BITS-1:0] gcode;
	wire [`OP_CMD_BITS-1:0] cmd;
	wire is_valid;

	GcodeToCmd #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.gcode(gcode),
		.cmd(cmd),
		.is_valid(is_valid)
	);

	initial begin
		`FOPEN("tests/tests/GcodeToCmd_tb.txt")

		gcode = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		gcode = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		gcode = 2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		gcode = 3;
		#(`CLOCK_PERIOD * 2);
		`LOG

		gcode = 90;
		#(`CLOCK_PERIOD * 2);
		`LOG

		gcode = 91;
		#(`CLOCK_PERIOD * 2);
		`LOG

		gcode = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : GcodeToCmd_tb
