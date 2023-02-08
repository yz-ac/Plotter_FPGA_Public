`include "uart/uart.svh"

/**
* Receives data on UART interface and stores it immediatly into a FIFO buffer -
* might lose data if buffer is full.
*
* :param CLKS_PER_BIT: Number of clock cycles per bit reading for UART.
* :param COUNTER_BITS: Field width of clock counter for UART.
* :param DATA_SIZE: Number of bits in a data packet (not including control signals).
* :param DATA_SIZE_BITS: Field width of the data.
* :input clk: System clock.
* :input reset: Resets the module.
* :input data_in: Input serial data.
* :input wr_done: Writer done.
* :input wr_rdy: Writer ready to accept triggers.
* :input is_full: FIFO buffer is full (might cause data loss).
* :output wr_trigger: Trigger write to FIFO buffer.
* :output data_out: Data to write.
*/
module UartToFifoBuf #(
	parameter CLKS_PER_BIT = `UART_CLKS_PER_BIT, // round(clk_freq / baudrate)
	parameter COUNTER_BITS = `UART_COUNTER_BITS, // clog2(CLKS_PER_BIT)
	parameter DATA_SIZE = `UART_DATA_SIZE, // 7/8
	parameter DATA_SIZE_BITS = `UART_DATA_SIZE_BITS // clog2(DATA_SIZE)
)
(
	input logic clk,
	input logic reset,
	input logic data_in,
	input logic wr_done,
	input logic wr_rdy,
	input logic is_full,

	output logic wr_trigger,
	output logic [DATA_SIZE-1:0] data_out
);

	wire _rx_done;
	wire _store;
	wire [DATA_SIZE-1:0] _data;
	reg [DATA_SIZE-1:0] _stored_data;

	UartRxController #(
		.CLKS_PER_BIT(CLKS_PER_BIT),
		.COUNTER_BITS(COUNTER_BITS),
		.DATA_SIZE(DATA_SIZE),
		.DATA_SIZE_BITS(DATA_SIZE_BITS)
	) _uart_rx (
		.clk(clk),
		.reset(reset),
		.data_in(data_in),
		.data_out(_data),
		.rx_done(_rx_done)
	);

	UartToFifoBuf_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.rx_done(_rx_done),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy),
		.is_full(is_full),
		.store(_store),
		.wr_trigger(wr_trigger)
	);

	assign data_out = _stored_data;

	always_ff @(posedge clk) begin
		if (reset) begin
			_stored_data <= 0;
		end
		else begin
			_stored_data <= _stored_data;
			if (_store) begin
				_stored_data <= _data;
			end
		end
	end // always_ff

endmodule : UartToFifoBuf
