`include "common/common.svh"

/**
* Pulse generator.
*
* :param PULSE_NUM_BITS: Field width of number of pulses.
* :param PULSE_WIDTH_BITS: Field width of pulse width.
* :input clk: System clock.
* :input reset: Resets the module.
* :input en: Enables the module.
* :input pulse_num: Number of pulses.
* :input pulse_width: Width of pulses (in clocks * en).
* :input trigger: Triggers the pulses.
* :output out: Output signal.
* :output done: Logic is finished and awaits new trigger.
*/
module PulseGen #(
	parameter PULSE_NUM_BITS = `BYTE_BITS,
	parameter PULSE_WIDTH_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic en,
	input logic [PULSE_NUM_BITS-1:0] pulse_num,
	input logic [PULSE_WIDTH_BITS-1:0] pulse_width,
	input logic trigger,

	output logic out,
	output logic done
);

	reg [PULSE_NUM_BITS-1:0] _last_pulse_num;
	reg [PULSE_WIDTH_BITS-1:0] _last_pulse_width;
	reg [PULSE_NUM_BITS-1:0] _num_counter;
	// Width counter counts to twice the 'on' width
	reg [PULSE_WIDTH_BITS:0] _width_counter;

	reg _num_reached_target;
	reg _width_reached_target;
	wire _counters_reached_target;
	wire _prepare;
	wire _working;

	reg _deglitch_out;

	PulseGen_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.en(en),
		.trigger(trigger),
		.counters_reached_target(_counters_reached_target),
		.prepare(_prepare),
		.working(_working)
	);

	always_comb begin
		_num_reached_target = _num_counter == _last_pulse_num - 1;
		_width_reached_target = _width_counter == (_last_pulse_width << 1) - 1;
		if ((~|_last_pulse_num) | (~|_last_pulse_width)) begin
			_num_reached_target = 1;
			_width_reached_target = 1;
		end
	end // always_comb

	assign _counters_reached_target = _num_reached_target & _width_reached_target;
	assign done = !_working;

	always_comb begin
		out = _working & (_width_counter < _last_pulse_width) & _deglitch_out & !_prepare;
		if ((~|_last_pulse_num) | (~|_last_pulse_width)) begin
			out = 0;
		end
	end // always_comb

	always_ff @(posedge clk) begin
		_deglitch_out <= 1;
		if (reset) begin
			_last_pulse_num <= pulse_num;
			_last_pulse_width <= pulse_width;
			_num_counter <= 0;
			_width_counter <= 0;
		end
		else if (en) begin
			_last_pulse_num <= pulse_num;
			_last_pulse_width <= pulse_width;
			_num_counter <= 0;
			_width_counter <= 0;
			if (_working & !_prepare) begin
				_last_pulse_num <= _last_pulse_num;
				_last_pulse_width <= _last_pulse_width;
				_num_counter <= _num_counter;
				_width_counter <= _width_counter + 1;
			end

			if (_width_reached_target) begin
				_width_counter <= 0;
				_num_counter <= _num_counter + 1;
				if (_num_reached_target) begin
					_num_counter <= 0;
					// Race between 'working' signal and counters causes glitch
					_deglitch_out <= 0;
				end
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
