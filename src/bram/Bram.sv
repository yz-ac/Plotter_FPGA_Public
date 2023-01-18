`include "common/common.svh"

/**
* Block RAM module.
*
* :param ROWS: Number of rows in the bram.
* :param COLS: Number of bits in each row.
* :param INIT_FILE: Hex file to initialize the BRAM with.
* :input clk: System clock.
* :input rd_addr: Address to read.
* :input wr_en: Enable write.
* :input wr_addr: Address to write to.
* :input wr_data: Data to write to 'wr_addr'.
* :output rd_data: Data read from 'rd_addr'.
*/
module Bram #(
	parameter ROWS = `BYTE_BITS,
	parameter COLS = `BYTE_BITS,
	parameter INIT_FILE = "",
	localparam ADDR_BITS = $clog2(ROWS)
)
(
	input logic clk,
	input logic [ADDR_BITS-1:0] rd_addr,
	input logic wr_en,
	input logic [ADDR_BITS-1:0] wr_addr,
	input logic [COLS-1:0] wr_data,

	output logic [COLS-1:0] rd_data
);

	reg [COLS-1:0] _mem [ROWS-1:0];

	// Not overflow safe.
	assign rd_data = _mem[rd_addr];

	initial begin
		if (INIT_FILE != "") begin
			$readmemh(INIT_FILE, _mem);
		end
	end // initial

	always_ff @(posedge clk) begin
		// If not wr_en _mem stays the same is inferred.
		if (wr_en) begin
			_mem[wr_addr] <= wr_data;
		end
	end // always_ff

endmodule : Bram
