`include "../../../src/common/common.svh"

module Bram_tb;

	localparam ADDR_BITS = 2;
	localparam DATA_BITS = `BYTE_BITS;

	reg clk;
	reg clear;
	reg [ADDR_BITS-1:0] rd_addr;
	reg wr_en;
	reg [ADDR_BITS-1:0] wr_addr;
	reg [DATA_BITS-1:0] wr_data;
	
	wire [DATA_BITS-1:0] rd_data;

	Bram #(
		.ADDR_BITS(ADDR_BITS),
		.DATA_BITS(DATA_BITS)
	) UUT (
		.clk(clk),
		.clear(clear),
		.rd_addr(rd_addr),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.wr_data(wr_data),
		.rd_data(rd_data)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 10 clks
	initial begin
		clear = 1;
		wr_en = 0;
		rd_addr = 0;
		wr_addr = 0;
		#(`CLOCK_PERIOD * 2);

		clear = 0;
		rd_addr = 1;
		wr_en = 1;
		wr_addr = 2;
		wr_data = 3;
		#(`CLOCK_PERIOD * 2);

		rd_addr = 2;
		wr_addr = 3;
		wr_data = 7;
		#(`CLOCK_PERIOD * 2);

		rd_addr = 3;
		wr_addr = 0;
		wr_data = 15;
		#(`CLOCK_PERIOD * 2);

		clear = 1;
		#(`CLOCK_PERIOD * 2);
	end

endmodule : Bram_tb
