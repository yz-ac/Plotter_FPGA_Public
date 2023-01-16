`include "common/common.svh"

/**
* Module to control given BRAM as a cyclic FIFO with synchronized reads / writes.
* Priority is given to read requests (to empty BRAM faster).
* When reading, 'write_done' and 'write_rdy' stay up (they go down only when
* writing is started) and vice versa.
*
* :param MAX_ROWS: Maximum rows in BRAM.
* :param PRELOADED_ROWS: How many rows of bram were preloaded in advance.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input rd_trigger: Triggers read from next row in BRAM.
* :input wr_trigger: Triggers write to next row in BRAM.
* :output rd_addr: Next address in BRAM to read.
* :output wr_en: Enables write to BRAM.
* :output wr_addr: Next address in BRAM to write to.
* :output is_empty: Is BRAM empty.
* :output is_full: Is BRAM full.
* :output rd_done: Done reading.
* :output rd_rdy: Ready to accept read triggers.
* :output wr_done: Done writing.
* :output wr_rdy: Ready to accept write triggers.
*/
module BramFifoCtrl #(
	parameter MAX_ROWS = `BYTE_BITS,
	parameter PRELOADED_ROWS = 0,
	localparam ADDR_BITS = $clog2(MAX_ROWS)
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_trigger,
	input logic wr_trigger,

	output logic [ADDR_BITS-1:0] rd_addr,
	output logic wr_en,
	output logic [ADDR_BITS-1:0] wr_addr,
	output logic is_empty,
	output logic is_full,
	output logic rd_done,
	output logic rd_rdy,
	output logic wr_done,
	output logic wr_rdy
);

	reg [ADDR_BITS-1:0] _rd_ptr;
	reg [ADDR_BITS-1:0] _wr_ptr;
	reg [ADDR_BITS:0] _occupied_rows;

	wire _update_rd_ptr;
	wire _update_wr_ptr;

	wire _is_empty;
	wire _is_full;

	BramFifoCtrl_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.rd_trigger(rd_trigger),
		.wr_trigger(wr_trigger),
		.is_empty(_is_empty),
		.is_full(_is_full),
		
		.wr_en(wr_en),
		.update_rd_ptr(_update_rd_ptr),
		.update_wr_ptr(_update_wr_ptr),
		.rd_done(rd_done),
		.rd_rdy(rd_rdy),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy)
	);

	function automatic bit [ADDR_BITS-1:0] inc_ptr_and_overlap (
		input logic [ADDR_BITS-1:0] ptr
	);

		if (ptr == MAX_ROWS) begin
			return 0;
		end
		else begin
			return ptr + 1;
		end

	endfunction

	assign _is_empty = ~|_occupied_rows;
	assign _is_full = (_occupied_rows == MAX_ROWS) ? 1 : 0;
	assign is_empty = _is_empty;
	assign is_full = _is_full;

	assign rd_addr = _rd_ptr;
	assign wr_addr = _wr_ptr;

	always_ff @(posedge clk) begin
		if (reset) begin
			_rd_ptr <= 0;
			_wr_ptr <= PRELOADED_ROWS;
			_occupied_rows <= PRELOADED_ROWS;
		end
		else if (clk_en) begin
			_rd_ptr <= _rd_ptr;
			_wr_ptr <= _wr_ptr;
			_occupied_rows <= _occupied_rows;
			if (_update_wr_ptr) begin
				_wr_ptr <= inc_ptr_and_overlap(_wr_ptr);
				_occupied_rows <= _occupied_rows + 1;
			end
			if (_update_rd_ptr) begin
				_rd_ptr <= inc_ptr_and_overlap(_rd_ptr);
				_occupied_rows <= _occupied_rows - 1;
			end
		end
		else begin
			_rd_ptr <= _rd_ptr;
			_wr_ptr <= _wr_ptr;
			_occupied_rows <= _occupied_rows;
		end
	end

endmodule : BramFifoCtrl
