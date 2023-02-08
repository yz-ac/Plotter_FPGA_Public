/**
* FSM for UartRxController.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input is_bit_low: Is serial data bit low (might indicate start bit).
* :input is_center_of_bit: Counter of clocks reached the center of a data bit.
* :input reached_num_clk: Counter of clocks reached clocks per bit.
* :input reached_num_bits: Reached number of data bits.
* :output reset_counter: Reset the clock counter.
* :output reset_data: Reset the output data (invalidate data).
* :output set_data_bit: Set the next bit in the output data.
* :output rx_done: Done receiving (high for one clock).
*/
module UartRxController_FSM (
	input logic clk,
	input logic reset,
	input logic is_bit_low,
	input logic is_center_of_bit,
	input logic reached_num_clks,
	input logic reached_num_bits,

	output logic reset_counter,
	output logic reset_data,
	output logic set_data_bit,
	output logic rx_done
);

	typedef enum {
		IDLE,
		START_BIT,
		DATA_BITS,
		STOP_BIT,
		DONE
	} UartRxController_state;

	UartRxController_state _cur_state;
	UartRxController_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			// Wait for start bit
			_nxt_state = IDLE;
			reset_counter = 1;
			reset_data = 0;
			set_data_bit = 0;
			rx_done = 0;

			if (is_bit_low) begin
				_nxt_state = START_BIT;
			end
		end
		START_BIT: begin
			// Wait until reaching the center of the bit
			_nxt_state = START_BIT;
			reset_counter = 0;
			reset_data = 0;
			set_data_bit = 0;
			rx_done = 0;

			if (is_center_of_bit) begin
				_nxt_state = DATA_BITS;
				reset_counter = 1;
				reset_data = 1;
				if (!is_bit_low) begin
					// Make sure center is still low
					_nxt_state = IDLE;
					reset_data = 0;
				end
			end
		end
		DATA_BITS: begin
			// At each center of bit advance data until reached number of bits
			_nxt_state = DATA_BITS;
			reset_counter = 0;
			reset_data = 0;
			set_data_bit = 0;
			rx_done = 0;

			if (reached_num_clks) begin
				reset_counter = 1;
				set_data_bit = 1;

				if (reached_num_bits) begin
					_nxt_state = STOP_BIT;
				end
			end
		end
		STOP_BIT: begin
			// Wait until center of stop bit
			_nxt_state = STOP_BIT;
			reset_counter = 0;
			reset_data = 0;
			set_data_bit = 0;
			rx_done = 0;

			if (reached_num_clks) begin
				_nxt_state = DONE;
			end
		end
		DONE: begin
			// Raise done for one cycle
			_nxt_state = IDLE;
			reset_counter = 0;
			reset_data = 0;
			set_data_bit = 0;
			rx_done = 1;
		end
		default: begin
			_nxt_state = IDLE;
			reset_counter = 1;
			reset_data = 0;
			set_data_bit = 0;
			rx_done = 0;
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

endmodule : UartRxController_FSM
