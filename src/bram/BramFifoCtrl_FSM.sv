/**
* FSM for BramFifoCtrl module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input rd_trigger: Trigger read.
* :input wr_trigger: Trigger write.
* :input is_empty: Is bram empty.
* :input is_full: Is bram full.
* :output wr_en: Enable write to bram.
* :output update_rd_ptr: Update reading pointer.
* :output update_wr_ptr: Update writing pointer.
* :output rd_done: Done reading from bram.
* :output rd_rdy: Ready to accept read triggers.
* :output wr_done: Done writing from bram.
* :output wr_rdy: Ready to accept write triggers.
*/
module BramFifoCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_trigger,
	input logic wr_trigger,
	input logic is_empty,
	input logic is_full,

	output logic wr_en,
	output logic update_rd_ptr,
	output logic update_wr_ptr,
	output logic rd_done,
	output logic rd_rdy,
	output logic wr_done,
	output logic wr_rdy
);

	typedef enum {
		IDLE,
		UPDATE_RD_PTR,
		DONE_READ,
		WRITE,
		UPDATE_WR_PTR,
		DONE_WRITE
	} BramFifoCtrl_state;

	BramFifoCtrl_state _cur_state;
	BramFifoCtrl_state _nxt_state;

	always_comb begin
	case (_cur_state)
	IDLE: begin
		_nxt_state = IDLE;
		wr_en = 0;
		update_rd_ptr = 0;
		update_wr_ptr = 0;
		rd_done = 1;
		rd_rdy = 1;
		wr_done = 1;
		wr_rdy = 1;
		// When reading, write done and ready stay up to avoid confusion upon race, and vice versa.
		if (wr_trigger & !is_full) begin
			_nxt_state = WRITE;
			wr_done = 0;
		end
		if (rd_trigger & !is_empty) begin
			_nxt_state = UPDATE_RD_PTR;
			rd_done = 0;
		end
	end
	UPDATE_RD_PTR: begin
		_nxt_state = DONE_READ;
		wr_en = 0;
		update_rd_ptr = 1;
		update_wr_ptr = 0;
		rd_done = 0;
		rd_rdy = 0;
		wr_done = 1;
		wr_rdy = 1;
	end
	DONE_READ: begin
		_nxt_state = IDLE;
		wr_en = 0;
		update_rd_ptr = 0;
		update_wr_ptr = 0;
		rd_done = 1;
		rd_rdy = 0;
		wr_done = 1;
		wr_rdy = 1;
	end
	WRITE: begin
		_nxt_state = UPDATE_WR_PTR;
		wr_en = 1;
		update_rd_ptr = 0;
		update_wr_ptr = 0;
		rd_done = 1;
		rd_rdy = 1;
		wr_done = 0;
		wr_rdy = 0;
	end
	UPDATE_WR_PTR: begin
		_nxt_state = DONE_WRITE;
		wr_en = 0;
		update_rd_ptr = 0;
		update_wr_ptr = 1;
		rd_done = 1;
		rd_rdy = 1;
		wr_done = 0;
		wr_rdy = 0;
	end
	DONE_WRITE: begin
		_nxt_state = IDLE;
		wr_en = 0;
		update_rd_ptr = 0;
		update_wr_ptr = 0;
		rd_done = 1;
		rd_rdy = 1;
		wr_done = 1;
		wr_rdy = 0;
	end
	default: begin
		_nxt_state = IDLE;
		wr_en = 0;
		update_rd_ptr = 0;
		update_wr_ptr = 0;
		rd_done = 1;
		rd_rdy = 1;
		wr_done = 1;
		wr_rdy = 1;
	end
	endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= IDLE;
		end
		else if (clk_en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : BramFifoCtrl_FSM
