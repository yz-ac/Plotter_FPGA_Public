`include "common/common.svh"

module FreqDivider #(
	DIV_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic en,
	input [DIV_BITS-1:0] div,

	output logic out
);

	reg [DIV_BITS-1:0] _counter;
	reg [DIV_BITS-1:0] _last_div;

	always_ff @(posedge clk) begin
		if (reset) begin
			_counter <= 0;
			_last_div <= div;
		end
		else if (en) begin
			_counter <= _counter + 1;
			if (!_last_div) begin
				_counter <= 0;
				_last_div <= div;
			end
			if (_counter == _last_div - 1) begin
				_counter <= 0;
				_last_div <= div;
			end
		end
		else begin
			_counter <= _counter;
			_last_div <= _last_div;
		end
	end // always_ff

	always_comb begin
		if (!_last_div) begin
			out = 0;
		end
		else if (_last_div == 1) begin
			out = clk & en;
		end
		else begin
			out = 0;
			if (_counter == _last_div - 1) begin
				out = 1;
			end
		end
	end // always_comb

endmodule : FreqDivider
