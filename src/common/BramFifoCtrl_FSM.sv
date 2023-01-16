module BramFifoCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_trigger,
	input logic wr_trigger,
	input logic is_empty,
	input logic is_full,

	output logic update_rd_ptr,
	output logic update_wr_ptr,
	output logic rd_done,
	output logic rd_rdy,
	output logic wr_done,
	output logic wr_rdy
);

	typedef enum {
		IDLE,
		READ,
		UPDATE_RD_PTR,
		WRITE,
		UPDATE_WR_PTR,
		DONE
	} BramFifoCtrl_state;

	BramFifoCtrl_state _cur_state;
	BramFifoCtrl_state _nxt_state;

	always_comb begin
	case (_cur_state)
	IDLE: begin
		_nxt_state = IDLE;
		update_rd_ptr = 0;
		update_wr_ptr = 0;
		rd_done = 1;
		rd_rdy = 1;
		wr_done = 1;
		wr_rdy = 1;
		if (wr_trigger & !is_full) begin
			_nxt_state = WRITE;
			wr_done = 0;
		end
		if (rd_trigger & !is_empty) begin
			_nxt_state = READ;
			rd_done = 0;
		end
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
