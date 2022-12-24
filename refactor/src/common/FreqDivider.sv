`include "common/common.svh"

/**
* Frequency divider for enable signals.
* 
* :param DIV_BITS: Field size of div signal.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Logic enabling clock.
* :input en: Enables the module.
* :input div: The number by which frequency is divided.
* :output out: Output signal.
*/
module FreqDivider #(
	parameter DIV_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
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
		else if (clk_en) begin
			_counter <= _counter + 1;
			_last_div <= _last_div;
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
		if (~|_last_div) begin
			out = 0;
		end
		else if (_last_div == 1) begin
			out = clk & en;
		end
		else begin
			out = 0;
			if (_counter == _last_div - 1) begin
				out = en;
			end
		end
	end // always_comb

endmodule : FreqDivider
