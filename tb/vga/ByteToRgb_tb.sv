`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, r: %d, g: %d, b: %d", $time, r_out, g_out, b_out))

module ByteToRgb_tb;
	int fd;

	reg [`BYTE_BITS-1:0] byte_in;
	wire [`BYTE_BITS-1:0] r_out;
	wire [`BYTE_BITS-1:0] g_out;
	wire [`BYTE_BITS-1:0] b_out;

	ByteToRgb UUT (
		.byte_in(byte_in),
		.r_out(r_out),
		.g_out(g_out),
		.b_out(b_out)
	);

	initial begin
		`FOPEN("tests/tests/ByteToRgb_tb.txt")

		byte_in = 'b11111111;
		#(`CLOCK_PERIOD * 2);
		`LOG

		byte_in = 'b00110000;
		#(`CLOCK_PERIOD * 2);
		`LOG

		byte_in = 'b00001100;
		#(`CLOCK_PERIOD * 2);
		`LOG

		byte_in = 'b00000011;
		#(`CLOCK_PERIOD * 2);
		`LOG

		byte_in = 'b00000000;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : ByteToRgb_tb
