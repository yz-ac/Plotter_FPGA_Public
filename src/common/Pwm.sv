`include "common/common.svh"

/**
* PWM module.
*
* :param PERIOD_BITS: Field width of period.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Logic enabling clock.
* :input period: Period of the PWM signal (in clk_en's).
* :input on_time: ON time of the PWM signal (in clk_en's).
* :output out: Output signal.
*/
module Pwm #(
	parameter PERIOD_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic [PERIOD_BITS-1:0] period,
	input logic [PERIOD_BITS-1:0] on_time,

	output logic out
);

	reg [PERIOD_BITS-1:0] _last_period;
	reg [PERIOD_BITS-1:0] _last_on_time;
	reg [PERIOD_BITS-1:0] _counter;

	wire _is_legal;

	assign _is_legal = ((_last_on_time <= _last_period) & (|_last_period)) ? 1 : 0;
	assign out = ((_is_legal) & (_counter <= _last_on_time)) ? 1 : 0;

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_period <= period;
			_last_on_time <= on_time;
			_counter <= 1;
		end
		else if (clk_en) begin
			_last_period <= _last_period;
			_last_on_time <= _last_on_time;
			_counter <= _counter + 1;
			if ((_counter == _last_period) | (!_is_legal)) begin
				_counter <= 1;
				_last_period <= period;
				_last_on_time <= on_time;
			end
		end
		else begin
			_last_period <= _last_period;
			_last_on_time <= _last_on_time;
			_counter <= _counter;
		end
	end // always_ff

endmodule : Pwm
