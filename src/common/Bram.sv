`include "common/common.svh"

module Bram #(
	parameter ROWS = `BYTE_BITS,
	parameter COLS = `BYTE_BITS,
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

	always_ff @(posedge clk) begin
		// If not wr_en _mem stays the same is inferred.
		if (wr_en) begin
			_mem[wr_addr] <= wr_data;
		end
	end // always_ff

endmodule : Bram
