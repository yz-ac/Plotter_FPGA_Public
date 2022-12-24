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

	reg [COUNTER_BITS-1:0] _last_count;
	reg [COUNTER_BITS-1:0] _counter;
	wire _reached_target;
	wire _working;

	Timer_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.reached_target(_reached_target),
		.working(_working)
	);

	assign _reached_target = ((_counter == _last_count) | (~|_last_count)) ? 1 : 0;
	assign done = !_working;

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_count <= count;
			_counter <= 1;
		end
		else if (clk_en) begin
			_last_count <= _last_count;
			_counter <= _counter + en;
			if (_counter == _last_count) begin
				_counter <= 1;
			end
			if (!_working) begin
				_last_count <= count;
				_counter <= 1;
			end
		end
		else begin
			_last_count <= _last_count;
			_counter <= _counter;
		end
	end // always_ff

endmodule : Timer
