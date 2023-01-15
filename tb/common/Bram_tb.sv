`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, rd_addr: %d, rd_data: %d, wr_addr: %d, wr_data: %d, wr_en: %d", $time, rd_addr, rd_data, wr_addr, wr_data, wr_en))
module Bram_tb;
	int fd;

	localparam ROWS = 2;
	localparam COLS = `BYTE_BITS;
	localparam ADDR_BITS = $clog2(ROWS);

	wire clk;
	reg [ADDR_BITS-1:0] rd_addr;
	reg wr_en;
	reg [ADDR_BITS-1:0] wr_addr;
	reg [COLS-1:0] wr_data;
	wire [COLS-1:0] rd_data;

	SimClock sim_clk (
		.out(clk)
	);

	Bram #(
		.ROWS(ROWS),
		.COLS(COLS)
	) UUT (
		.clk(clk),
		.rd_addr(rd_addr),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.wr_data(wr_data),
		.rd_data(rd_data)
	);

	initial begin
		`FOPEN("tests/tests/Bram_tb.txt")

		rd_addr = 0;
		wr_addr = 0;
		wr_en = 1;
		wr_data = 5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		wr_addr = 1;
		wr_data = 3;
		#(`CLOCK_PERIOD * 2);
		`LOG

		wr_en = 0;
		wr_addr = 0;
		rd_addr = 1;
		#(`CLOCK_PERIOD * 2);
		`LOG

		rd_addr = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : Bram_tb
