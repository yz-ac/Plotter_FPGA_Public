`include "common/common.svh"

/**
* A BRAM buffer controlled in a cyclic FIFO manner.
*
* :param ROWS: Number of rows in the buffer.
* :param COLS: Number of columns in each row.
* :param INIT_FILE: Optional hex file to initialize buffer.
* :param PRELOADED_ROWS: If 'INIT_FILE' is specified - number of rows in the file.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input rd_trigger: Triggers read from buffer.
* :input wr_trigger: Trigger write to buffer.
* :input wr_data: Data to write to buffer.
* :output rd_data: Data read from buffer.
* :output is_empty: Is buffer empty (can't read from it).
* :output is_full: Is buffer full (can't write to it).
* :output rd_done: Done reading from buffer.
* :output rd_rdy: Ready to accept read triggers.
* :outptu wr_done: Done writing to buffer.
* :output wr_rdy: Ready to accept write triggers.
*/
module FifoBuffer #(
	parameter ROWS = `BYTE_BITS,
	parameter COLS = `BYTE_BITS,
	parameter INIT_FILE = "",
	parameter PRELOADED_ROWS = 0,
	localparam ADDR_BITS = $clog2(ROWS)
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_trigger,
	input logic wr_trigger,
	input logic [COLS-1:0] wr_data,

	output logic [COLS-1:0] rd_data,
	output logic is_empty,
	output logic is_full,
	output logic rd_done,
	output logic rd_rdy,
	output logic wr_done,
	output logic wr_rdy
);

	wire [ADDR_BITS-1:0] _rd_addr;
	wire [ADDR_BITS-1:0] _wr_addr;
	wire _wr_en;

	Bram #(
		.ROWS(ROWS),
		.COLS(COLS),
		.INIT_FILE(INIT_FILE)
	) _bram (
		.clk(clk),
		.rd_addr(_rd_addr),
		.wr_en(_wr_en),
		.wr_addr(_wr_addr),
		.wr_data(wr_data),
		.rd_data(rd_data)
	);

	BramFifoCtrl #(
		.MAX_ROWS(ROWS),
		.PRELOADED_ROWS(PRELOADED_ROWS)
	) _fifo_ctrl (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.rd_trigger(rd_trigger),
		.wr_trigger(wr_trigger),
		.rd_addr(_rd_addr),
		.wr_en(_wr_en),
		.wr_addr(_wr_addr),
		.is_empty(is_empty),
		.is_full(is_full),
		.rd_done(rd_done),
		.rd_rdy(rd_rdy),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy)
	);

endmodule : FifoBuffer
