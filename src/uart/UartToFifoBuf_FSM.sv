/**
* FSM for UartToFifoBuf module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input rx_done: Received a data on UART interface.
* :input wr_done: Writer done.
* :input wr_rdy: Writer ready to accept triggers.
* :input is_full: FIFO buffer is full.
* :output store: Store received data (to avoid losing it).
* :output wr_trigger: Trigger writer.
*/
module UartToFifoBuf_FSM (
	input logic clk,
	input logic reset,
	input logic rx_done,
	input logic wr_done,
	input logic wr_rdy,
	input logic is_full,
	
	output logic store,
	output logic wr_trigger
);

	typedef enum {
		IDLE,
		WR_WAIT_RDY,
		WR_TRIGGER,
		WR_WAIT_DONE
	} UartToFifoBuf_state;

	UartToFifoBuf_state _cur_state;
	UartToFifoBuf_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			store = 0;
			wr_trigger = 0;

			if (rx_done) begin
				_nxt_state = WR_WAIT_RDY;
				// Store immediatly to prevent data loss.
				store = 1;
			end
		end
		WR_WAIT_RDY: begin
			_nxt_state = WR_WAIT_RDY;
			store = 0;
			wr_trigger = 0;

			if (wr_rdy & !is_full) begin
				_nxt_state = WR_TRIGGER;
			end
		end
		WR_TRIGGER: begin
			_nxt_state = WR_TRIGGER;
			store = 0;
			wr_trigger = 1;

			if (!wr_rdy) begin
				_nxt_state = WR_WAIT_DONE;
			end
		end
		WR_WAIT_DONE: begin
			_nxt_state = WR_WAIT_DONE;
			store = 0;
			wr_trigger = 0;

			if (wr_done) begin
				_nxt_state = IDLE;
			end
		end
		default: begin
			_nxt_state = IDLE;
			store = 0;
			wr_trigger = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= IDLE;
		end
		else begin
			_cur_state <= _nxt_state;
		end
	end // always_ff

endmodule : UartToFifoBuf_FSM
