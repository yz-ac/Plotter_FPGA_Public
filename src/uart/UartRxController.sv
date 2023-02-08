`include "uart/uart.svh"

/**
* UART RX controller.
*
* :param CLKS_PER_BIT: Number of clock cycles per bit reading.
* :param COUNTER_BITS: Field width of clock counter.
* :param DATA_SIZE: Number of bits in a data packet (not including control signals).
* :param DATA_SIZE_BITS: Field width of the data.
* :input clk: System clock.
* :input reset: Resets the module.
* :input data_in: Serial input data.
* :output data_out: Output data.
* :output rx_done: Done receiving a data packet (high for one clock after receiving).
*/
module UartRxController #(
	parameter CLKS_PER_BIT = `UART_CLKS_PER_BIT, // round(clk_freq / baudrate)
	parameter COUNTER_BITS = `UART_COUNTER_BITS, // clog2(CLKS_PER_BIT)
	parameter DATA_SIZE = `UART_DATA_SIZE, // 7/8
	parameter DATA_SIZE_BITS = `UART_DATA_SIZE_BITS // clog2(DATA_SIZE)
)
(
	input logic clk,
	input logic reset,
	input logic data_in,
	output logic [DATA_SIZE-1:0] data_out,
	output logic rx_done
);

	reg [DATA_SIZE-1:0] _data_out;
	reg [COUNTER_BITS-1:0] _clk_counter;
	reg [DATA_SIZE_BITS-1:0] _bit_counter;
	reg _data_in_1;
	reg _data_in_2;

	wire _is_bit_low;
	wire _is_center_of_bit;
	wire _reached_num_clks;
	wire _reached_num_bits;
	wire _reset_counter;
	wire _reset_data_out;
	wire _set_data_out_bit;

	UartRxController_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.is_bit_low(_is_bit_low),
		.is_center_of_bit(_is_center_of_bit),
		.reached_num_clks(_reached_num_clks),
		.reached_num_bits(_reached_num_bits),
		.reset_counter(_reset_counter),
		.reset_data(_reset_data_out),
		.set_data_bit(_set_data_out_bit),
		.rx_done(rx_done)
	);

	assign data_out = _data_out;
	assign _is_bit_low = ~_data_in_2;
	assign _is_center_of_bit = (_clk_counter == ((CLKS_PER_BIT - 1) >> 1)) ? 1 : 0;
	assign _reached_num_clks = (_clk_counter == CLKS_PER_BIT - 1) ? 1 : 0;
	assign _reached_num_bits =  (_bit_counter == DATA_SIZE - 1) ? 1 : 0;

	always_ff @(posedge clk) begin
		if (reset) begin
			_data_in_1 <= 0;
			_data_in_2 <= 0;
			_data_out <= 0;
			_clk_counter <= 0;
			_bit_counter <= 0;
		end
		else begin
			// Double-sample to prevent metastability problems
			_data_in_1 <= data_in;
			_data_in_2 <= _data_in_1;

			_data_out <= _data_out;
			_clk_counter <= _clk_counter + 1;
			_bit_counter <= _bit_counter;

			if (_set_data_out_bit) begin
				_data_out[_bit_counter] <= _data_in_2;
				_bit_counter <= _bit_counter + 1;
			end

			if (_reset_counter) begin
				_clk_counter <= 0;
			end

			if (_reset_data_out) begin
				_data_out <= 0;
				_bit_counter <= 0;
			end
		end
	end // always_ff

endmodule : UartRxController
