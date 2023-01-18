`include "common/common.svh"

module BramReader #(
	parameter DATA_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic is_empty,
	input logic bram_done,
	input logic bram_rdy,
	input logic reader_done,
	input logic reader_rdy,
	input logic [DATA_BITS-1:0] bram_data,

	output logic bram_trigger,
	output logic reader_trigger,
	output logic [DATA_BITS-1:0] reader_data
);

	wire _store_data;
	reg [DATA_BITS-1:0] _last_data;

	BramReader_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.is_empty(is_empty),
		.bram_done(bram_done),
		.bram_rdy(bram_rdy),
		.reader_done(reader_done),
		.reader_rdy(reader_rdy),
		.bram_trigger(bram_trigger),
		.reader_trigger(reader_trigger),
		.store_data(_store_data)
	);

	assign reader_data = _last_data;

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_data <= bram_data;
		end	
		else if (clk_en) begin
			_last_data <= _last_data;
			if (_store_data) begin
				_last_data <= bram_data;
			end
		end
		else begin
			_last_data <= _last_data;
		end
	end // always_ff

endmodule : BramReader
