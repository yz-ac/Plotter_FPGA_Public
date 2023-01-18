module BramReader_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic is_empty,
	input logic bram_done,
	input logic bram_rdy,
	input logic reader_done,
	input logic reader_rdy,

	output logic bram_trigger,
	output logic reader_trigger,
	output logic store_data
);

	typedef enum {
		IDLE,
		STORE_DATA,
		TRIGGER_BRAM,
		WAIT_BRAM,
		TRIGGER_READER,
		WAIT_READER
	} BramReader_state;

	BramReader_state _cur_state;
	BramReader_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			bram_trigger = 0;
			reader_trigger = 0;
			store_data = 0;
			if (bram_rdy & !is_empty) begin
				_nxt_state = STORE_DATA;
			end
		end
		STORE_DATA: begin
			_nxt_state = TRIGGER_BRAM;
			bram_trigger = 0;
			reader_trigger = 0;
			store_data = 1;
		end
		TRIGGER_BRAM: begin
			_nxt_state = TRIGGER_BRAM;
			bram_trigger = 1;
			reader_trigger = 0;
			store_data = 0;
			if (!bram_rdy) begin
				_nxt_state = WAIT_BRAM;
			end
		end
		WAIT_BRAM: begin
			_nxt_state = WAIT_BRAM;
			bram_trigger = 0;
			reader_trigger = 0;
			store_data = 0;
			if (bram_done & reader_rdy) begin
				_nxt_state = TRIGGER_READER;
			end
		end
		TRIGGER_READER: begin
			_nxt_state = TRIGGER_READER;
			bram_trigger = 0;
			reader_trigger = 1;
			store_data = 0;
			if (!reader_rdy) begin
				_nxt_state = WAIT_READER;
			end
		end
		WAIT_READER: begin
			_nxt_state = WAIT_READER;
			bram_trigger = 0;
			reader_trigger = 0;
			store_data = 0;
			if (reader_done) begin
				_nxt_state = IDLE;
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

endmodule : BramReader_FSM
