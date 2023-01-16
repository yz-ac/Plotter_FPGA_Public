`include "common/common.svh"

module BramFifoCtrl #(
	parameter ADDR_BITS = `BYTE_BITS,
	parameter DATA_BITS = `BYTE_BITS,
	parameter MAX_ROWS = `BYTE_BITS,
	parameter PRELOADED_ROWS = 0
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_trigger,
	input logic wr_trigger,
	input logic [DATA_BITS-1:0] wr_data,

	output logic [DATA_BITS-1:0] rd_data,
	output logic rd_done,
	output logic rd_rdy,
	output logic wr_done,
	output logic wr_rdy
);

	reg [DATA_BITS-1:0] _last_rd_data;
	reg [ADDR_BITS-1:0] _rd_ptr;
	reg [ADDR_BITS-1:0] _wr_ptr;
	reg [ADDR_BITS-1:0] _occupied_rows;

	wire _update_rd_ptr;
	wire _update_wr_ptr;
	wire _rd_rdy;
	wire _wr_rdy;

	wire _is_empty;
	wire _is_full;

	assign _is_empty = ~|_occupied_rows;
	assign _is_full = (_occupied_rows == MAX_ROWS) ? 1 : 0;

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_rd_data <= 0;
			_rd_ptr <= 0;
			_wr_ptr <= PRELOADED_ROWS;
			_occupied_rows <= PRELOADED_ROWS;
		end
		else if (clk_en) begin
			_last_rd_data <= _last_rd_data;
			_rd_ptr <= _rd_ptr;
			_wr_ptr <= _wr_ptr;
			_occupied_rows <= _occupied_rows;

		end
		else begin
			_last_rd_data <= _last_rd_data;
			_rd_ptr <= _rd_ptr;
			_wr_ptr <= _wr_ptr;
			_occupied_rows <= _occupied_rows;
		end
	end

endmodule : BramFifoCtrl
