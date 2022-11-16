`include "../common/common.svh"

/**
* BRAM module with simultaneous RW.
*
* :param ADDR_BITS: Number of bits for the address field.
* :param DATA_BITS: Number of bits for data field.
* :input clk: System clock.
* :input clear: Clears the RAM.
* :input rd_addr: Address to read.
* :input wr_en: Enable write to memory.
* :input wr_addr: Address to write to.
* :input wr_data: Data to write.
* :output rd_data: Read data.
*/
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
			rd_data <= 0;
		end
		else begin
			rd_data <= mem[rd_addr];
			if (wr_en) begin
				mem[wr_addr] <= wr_data;
			end
		end
	end // always_ff

endmodule : Bram
