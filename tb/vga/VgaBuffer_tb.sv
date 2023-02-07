`include "tb/simulation.svh"
`include "common/common.svh"
`include "vga/vga.svh"

`define LOG() \
		`FWRITE(("time: %t, byte_out: %d", $time, byte_out))

module VgaBuffer_tb;
	int fd;

	wire clk;
	reg [`VGA_H_BITS-1:0] rd_x;
	reg [`VGA_V_BITS-1:0] rd_y;
	reg wr_en;
	reg [`VGA_H_BITS-1:0] wr_x;
	reg [`VGA_V_BITS-1:0] wr_y;
	reg [`BYTE_BITS-1:0] byte_in;
	wire [`BYTE_BITS-1:0] byte_out;

	SimClock sim_clk (
		.out(clk)
	);

	VgaBuffer UUT (
		.clk(clk),
		.rd_x(rd_x),
		.rd_y(rd_y),
		.wr_en(wr_en),
		.wr_x(wr_x),
		.wr_y(wr_y),
		.byte_in(byte_in),
		.byte_out(byte_out)
	);

	initial begin
		`FOPEN("tests/tests/VgaBuffer_tb.txt")

		rd_x = 0;
		rd_y = 0;
		wr_en = 0;
		wr_x = 0;
		wr_y = 0;
		byte_in = 'b00110011;
		#(`CLOCK_PERIOD * 2);
		`LOG

		wr_en = 1;
		wr_x = 100;
		wr_y = 100;
		#(`CLOCK_PERIOD * 2);
		`LOG

		rd_x = 100;
		rd_y = 100;
		wr_en = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		rd_x = 200;
		rd_y = 50;
		#(`CLOCK_PERIOD * 2);
		`LOG

		wr_en = 1;
		wr_x = 200;
		wr_y = 50;
		#(`CLOCK_PERIOD * 2);
		`LOG

		wr_en = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : VgaBuffer_tb
