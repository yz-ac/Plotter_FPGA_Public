`include "common/common.svh"
`include "motors/motors.svh"
`include "vga/vga.svh"

/**
* Inner logic for MotorSignalsToVga module - counts pulses and sets outputs
* for VGA buffer.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock (NOT pixel clock).
* :input motors_signal_x: Motors signal 'out_x'.
* :input motors_dir_x: Motors signal 'dir_x'.
* :input motors_signal_y: Motors signal 'out_y'.
* :input motors_dir_y: Motors signal 'dir_y'.
* :input should_draw: Is currently drawing (servo up or down).
* :output wr_en: Should write to VGA buffer.
* :output wr_x: Current X position.
* :output wr_y: Current Y position.
* :output byte_out: Byte to store in VGA buffer.
*/
module MotorSignalsToVga_InnerLogic #(
	parameter PULSE_NUM_X_FACTOR = `STEPPER_PULSE_NUM_X_FACTOR,
	parameter PULSE_NUM_Y_FACTOR = `STEPPER_PULSE_NUM_Y_FACTOR
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic motors_signal_x,
	input logic motors_dir_x,
	input logic motors_signal_y,
	input logic motors_dir_y,
	input logic should_draw,

	output logic wr_en,
	output logic [`VGA_H_BITS-1:0] wr_x,
	output logic [`VGA_V_BITS-1:0] wr_y,
	output logic [`BYTE_BITS-1:0] byte_out
);

	localparam X_COUNTER_BITS = $clog2(PULSE_NUM_X_FACTOR) + 1;
	localparam Y_COUNTER_BITS = $clog2(PULSE_NUM_Y_FACTOR) + 1;

	reg [`POS_X_BITS-1:0] _pos_x;
	reg [`POS_Y_BITS-1:0] _pos_y;
	reg [X_COUNTER_BITS-1:0] _x_counter;
	reg [Y_COUNTER_BITS-1:0] _y_counter;
	reg _last_x_sig;
	reg _last_y_sig;

	assign wr_en = should_draw;
	assign wr_x = _pos_x[`VGA_H_BITS-1:0];
	assign wr_y = _pos_y[`VGA_V_BITS-1:0];
	assign byte_out = 8'b11111111;

	always_ff @(posedge clk) begin
		if (reset) begin
			_pos_x <= 0;
			_pos_y <= `VGA_ROWS;
			_x_counter <= 0;
			_y_counter <= 0;
			_last_x_sig <= motors_signal_x;
			_last_y_sig <= motors_signal_y;
		end
		else if (clk_en) begin
			_pos_x <= _pos_x;
			_pos_y <= _pos_y;
			_x_counter <= _x_counter;
			_y_counter <= _y_counter;
			_last_x_sig <= _last_x_sig;
			_last_y_sig <= _last_y_sig;

			// Handle X pulses
			if (_last_x_sig != motors_signal_x) begin
				_last_x_sig <= motors_signal_x;
				if (motors_signal_x) begin
					// posedge motors_signal_x
					_x_counter <= _x_counter + 1;
					if (_x_counter == PULSE_NUM_X_FACTOR - 1) begin
						_x_counter <= 0;
						_pos_x <= (motors_dir_x) ? (_pos_x - 1) : (_pos_x + 1);
					end
				end
			end

			// Handle Y pulses
			if (_last_y_sig != motors_signal_y) begin
				_last_y_sig <= motors_signal_y;
				if (motors_signal_y) begin
					// posedge motors_signal_y
					_y_counter <= _y_counter + 1;
					if (_y_counter == PULSE_NUM_Y_FACTOR - 1) begin
						_y_counter <= 0;
						// Raster goes top to bottom (origin is top left).
						_pos_y <= (motors_dir_y) ? (_pos_y + 1) : (_pos_y - 1);
					end
				end
			end
		end
		else begin
			_pos_x <= _pos_x;
			_pos_y <= _pos_y;
			_x_counter <= _x_counter;
			_y_counter <= _y_counter;
			_last_x_sig <= _last_x_sig;
			_last_y_sig <= _last_y_sig;
		end
	end // always_ff

endmodule : MotorSignalsToVga_InnerLogic
