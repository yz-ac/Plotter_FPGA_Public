`include "common/common.svh"

/**
* Pulse generator - generates pulses with 50% duty cycle.
*
* :param PULSE_NUM_BITS: Field width of number of pulses.
* :param PULSE_WIDTH_BITS: Field width of pulse width.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Logic enabling clock.
* :input pulse_num: Number of pulses.
* :input pulse_width: Width of pulses (in clk_en's).
* :input trigger: Triggers the pulses.
* :output out: Output signal.
* :output done: Logic is finished.
* :output rdy: Ready to accept new triggers.
*/
module PulseGen #(
	parameter PULSE_NUM_BITS = `BYTE_BITS,
	parameter PULSE_WIDTH_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic [PULSE_NUM_BITS-1:0] pulse_num,
	input logic [PULSE_WIDTH_BITS-1:0] pulse_width,
	input logic trigger,

	output logic out,
	output logic done,
	output logic rdy
);

	reg [PULSE_NUM_BITS-1:0] _last_pulse_num;
	reg [PULSE_WIDTH_BITS-1:0] _last_pulse_width;
	reg [PULSE_NUM_BITS-1:0] _num_counter;
	// Counter is twice the 'on' width
	reg [PULSE_WIDTH_BITS:0] _width_counter;

	wire _num_reached_target;
	wire _width_reached_target;
	wire _counters_reached_target;
	wire _done;
	wire _rdy;
	wire _zero_pulse;

	PulseGen_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.counters_reached_target(_counters_reached_target),
		.done(_done),
		.rdy(_rdy)
	);

	assign _num_reached_target = _num_counter == _last_pulse_num - 1;
	assign _width_reached_target = _width_counter == (_last_pulse_width << 1) - 1;
	assign _counters_reached_target = _num_reached_target & _width_reached_target | _zero_pulse;
	assign done = _done;
	assign rdy = _rdy;
	assign _zero_pulse = (~|_last_pulse_num) | (~|_last_pulse_width);

	always_comb begin
		out = (_width_counter < _last_pulse_width) & (!_done);
		if (_zero_pulse) begin
			out = 0;
		end
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_pulse_num <= pulse_num;
			_last_pulse_width <= pulse_width;
			_num_counter <= 0;
			_width_counter <= 0;
		end
		else if (clk_en) begin
			_num_counter <= _num_counter;
			_width_counter <= _width_counter;
			_last_pulse_num <= _last_pulse_num;
			_last_pulse_width <= _last_pulse_width;
			if (!_done) begin
				_width_counter <= _width_counter + 1;
				if (_width_reached_target) begin
					_width_counter <= 0;
					_num_counter <= _num_counter + 1;
				end
			end
			if (_rdy & trigger) begin
				_last_pulse_num <= pulse_num;
				_last_pulse_width <= pulse_width;
				_num_counter <= 0;
				_width_counter <= 0;
			end
		end
		else begin
			_last_pulse_num <= _last_pulse_num;
			_last_pulse_width <= _last_pulse_width;
			_num_counter <= _num_counter;
			_width_counter <= _width_counter;
		end
	end // always_ff

endmodule : PulseGen
