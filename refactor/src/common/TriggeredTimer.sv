`include "common/common.svh"

/**
* Timer that can be triggered.
*
* :param COUNTER_BITS: Field with of count signal.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input en: Enables the module.
* :input count: Number of cycles to count (in clk_en's).
* :input trigger: Triggers counting.
* :output done: Logic is done.
* :output rdy: Ready to accept new triggers.
*/
module TriggeredTimer #(
	parameter COUNTER_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic en,
	input [COUNTER_BITS-1:0] count,
	input logic trigger,

	output logic done,
	output logic rdy
);

	reg [COUNTER_BITS-1:0] _counter;
	wire _reached_zero;
	wire _done;
	wire _rdy;

	TriggeredTimer_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.reached_zero(_reached_zero),
		.done(_done),
		.rdy(_rdy)
	);

	assign _reached_zero = (_counter == 0) ? 1 : 0;
	assign done = _done;
	assign rdy = _rdy;


	always_ff @(posedge clk) begin
		if (reset) begin
			_counter <= count;
		end
		else if (clk_en) begin
			_counter <= _counter;
			if (!_done) begin
				_counter <= _counter - en;
			end
			if (_rdy & trigger) begin
				_counter <= count;
			end
		end
		else begin
			_counter <= _counter;
		end
	end // always_ff

endmodule : TriggeredTimer
