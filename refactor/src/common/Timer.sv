`include "common/common.svh"

module Timer #(
	parameter COUNTER_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic en,
	input [COUNTER_BITS-1:0] count,
	input logic trigger,

	output logic done
);

	reg [COUNTER_BITS-1:0] _counter;
	wire _reached_zero;
	wire _working;

	Timer_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.reached_zero(_reached_zero),
		.working(_working)
	);

	assign _reached_zero = (_counter == 0) ? 1 : 0;
	assign done = !_working;

	always_ff @(posedge clk) begin
		if (reset) begin
			_counter <= count;
		end
		else if (clk_en) begin
			_counter <= _counter;
			if (!_working & trigger) begin
				_counter <= count;
			end
			if (_working) begin
				_counter <= _counter - en;
			end
		end
		else begin
			_counter <= _counter;
		end
	end // always_ff

endmodule : Timer
