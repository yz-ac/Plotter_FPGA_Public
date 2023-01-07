`include "common/common.svh"

/**
* Computes integer sqrt of a number using binary search.
*
* :param NUM_BITS: Bits in number field.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input num_in: Number of which int sqrt to compute.
* :input trigger: Triggers computation.
* :output sqrt_out: Result of integer sqrt computation, valid on 'done'='1'.
* :output done: Computation is done - 'sqrt_out' is valid only if 'done'='1'.
* :output rdy: Module is ready to accept new trigger.
*/
module IntSqrt #(
	parameter NUM_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic [NUM_BITS-1:0] num_in,
	input logic trigger,

	output logic [NUM_BITS-1:0] sqrt_out,
	output logic done,
	output logic rdy
);

	wire _done;
	wire _rdy;
	wire _found;
	reg [NUM_BITS-1:0] _last_num_in;
	reg [NUM_BITS-1:0] _left;
	reg [NUM_BITS-1:0] _right;
	wire [NUM_BITS:0] _mid;
	wire [2*NUM_BITS-1:0] _guess;
	wire [2*NUM_BITS-1:0] _extended_num;

	assign _mid = (_left + _right) >> 1;
	assign _extended_num = {{NUM_BITS{1'b0}}, _last_num_in[NUM_BITS-1:0]};
	assign _guess = _mid * _mid;
	assign _found = ((~|_last_num_in) | (_left >= _right - 1)) ? 1 : 0;
	assign sqrt_out = _left;
	assign done = _done;
	assign rdy = _rdy;

	function automatic logic [NUM_BITS-1:0] get_range_min (
		input logic [NUM_BITS-1:0] num
	);

		if (~|num) begin
			return 0;
		end
		else begin
			return 1;
		end

	endfunction : get_range_min

	IntSqrt_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.found(_found),
		.done(_done),
		.rdy(_rdy)
	);

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_num_in <= num_in;
			_left <= get_range_min(num_in);
			_right <= num_in;
		end
		else if (clk_en) begin
			_last_num_in <= _last_num_in;
			_left <= _left;
			_right <= _right;
			if (!_done) begin
				if (_guess <= _extended_num) begin
					_left <= _mid;
				end
				else begin
					_right <= _mid;
				end
			end
			if (_rdy & trigger) begin
				_last_num_in <= num_in;
				_left <= get_range_min(num_in);
				_right <= num_in;
			end
		end
		else begin
			_last_num_in <= _last_num_in;
			_left <= _left;
			_right <= _right;
		end
	end // always_ff

endmodule : IntSqrt
