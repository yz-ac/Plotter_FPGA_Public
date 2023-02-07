`include "common/common.svh"
`include "vga/vga.svh"

/**
* Buffer for displaying images through VGA.
*
* :input clk: System clock.
* :input rd_x: X coordinate to read from.
* :input rd_y: Y coordinate to read from.
* :input wr_en: Enable writing to buffer.
* :input wr_x: X coordinate to write to.
* :input wr_y: Y coordinate to write to.
* :input byte_in: Byte to write.
* :output byte_out: Read byte.
*/
module VgaBuffer #(
	parameter INIT_FILE = "data/vga_buf_init.mem"
)
(
	input logic clk,
	input logic [`VGA_H_BITS-1:0] rd_x,
	input logic [`VGA_V_BITS-1:0] rd_y,
	input logic wr_en,
	input logic [`VGA_H_BITS-1:0] wr_x,
	input logic [`VGA_V_BITS-1:0] wr_y,
	input logic [`BYTE_BITS-1:0] byte_in,

	output logic [`BYTE_BITS-1:0] byte_out
);

	localparam COLS = `BYTE_BITS;
	localparam ROWS = `VGA_ROWS * `VGA_COLS;
	localparam ADDR_BITS = $clog2(ROWS);

	wire _valid_rd_addr;
	wire _valid_wr_addr;
	wire _wr_en;
	wire [ADDR_BITS-1:0] _rd_addr;
	wire [ADDR_BITS-1:0] _wr_addr;

	Bram #(
		.ROWS(ROWS),
		.COLS(COLS),
		.INIT_FILE(INIT_FILE)
	) _bram (
		.clk(clk),
		.rd_addr(_rd_addr),
		.wr_en(_wr_en),
		.wr_addr(_wr_addr),
		.wr_data(byte_in),
		.rd_data(byte_out)
	);

	assign _valid_rd_addr = ((rd_x < `VGA_COLS) & (rd_y < `VGA_ROWS)) ? 1 : 0;
	assign _valid_wr_addr = ((wr_x < `VGA_COLS) & (wr_y < `VGA_ROWS)) ? 1 : 0;
	assign _wr_en = wr_en & _valid_wr_addr;
	// Row stack configuration
	assign _rd_addr = (rd_y * `VGA_COLS) + rd_x;
	assign _wr_addr = (wr_y * `VGA_COLS) + wr_x;

endmodule : VgaBuffer
