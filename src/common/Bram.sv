`include "../common/common.svh"

module Bram #(
	ADDR_BITS = `BYTE_BITS,
	DATA_BITS = `QWORD_BITS
)
(
	input logic clk,
	input logic clear,
	input logic [ADDR_BITS-1:0] rd_addr,
	input logic wr_en,
	input logic [ADDR_BITS-1:0] wr_addr,
	input logic [DATA_BITS-1:0] wr_data,
	output logic [DATA_BITS-1:0] rd_data
);

	reg [DATA_BITS-1:0] mem [2**ADDR_BITS-1:0];

	always_ff @(posedge clk) begin
		if (clear) begin
			integer i;
			for (i = 0; i < 2**ADDR_BITS; i = i + 1) begin
				mem[i] <= 0;
			end
		end
		else begin
			rd_data <= mem[rd_addr];
			if (wr_en) begin
				mem[wr_addr] <= wr_data;
			end
		end
	end // always_ff

endmodule : Bram
