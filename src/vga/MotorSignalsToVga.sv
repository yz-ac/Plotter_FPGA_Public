`include "common/common.svh"
`include "motors/motors.svh"
`include "vga/vga.svh"

/**
* Translates motors signals (step, dir and servo_pos) to a VGA drawing.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock (NOT pixel clock).
* :input motors_signal_x: Motors X step signal 'out_x'.
* :input motors_dir_x: Motors X direction signal 'dir_x'.
* :input motors_signal_y: Motors Y step signal 'out_y'.
* :input motors_dir_y: Motors Y direction signal 'dir_y'.
* :input should_draw: Is currently drawing (is servo up or down).
* :input trace_path: Should rapid movements be visible.
* :input clear_screen: Clear the screen.
* :output r_out: Red signal to monitor.
* :output g_out: Green signal to monitor.
* :output b_out: Blue signal to monitor.
* :output h_sync: Horizontal sync to monitor.
* :output v_sync: Vertical sync to monitor.
*/
module MotorSignalsToVga #(
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
	input logic trace_path,
	input logic clear_screen,

	output logic [`BYTE_BITS-1:0] r_out,
	output logic [`BYTE_BITS-1:0] g_out,
	output logic [`BYTE_BITS-1:0] b_out,
	output logic h_sync,
	output logic v_sync
);

	wire _wr_en;
	wire [`VGA_H_BITS-1:0] _wr_x;
	wire [`VGA_V_BITS-1:0] _wr_y;
	wire [`BYTE_BITS-1:0] _wr_byte;

	wire [`VGA_H_BITS-1:0] _rd_x;
	wire [`VGA_V_BITS-1:0] _rd_y;
	wire [`BYTE_BITS-1:0] _rd_byte;

	wire [`BYTE_BITS-1:0] _red;
	wire [`BYTE_BITS-1:0] _green;
	wire [`BYTE_BITS-1:0] _blue;

	wire _vga_clk;

	MotorSignalsToVga_InnerLogic #(
		.PULSE_NUM_X_FACTOR(PULSE_NUM_X_FACTOR),
		.PULSE_NUM_Y_FACTOR(PULSE_NUM_Y_FACTOR)
	) _inner_logic (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.motors_signal_x(motors_signal_x),
		.motors_dir_x(motors_dir_x),
		.motors_signal_y(motors_signal_y),
		.motors_dir_y(motors_dir_y),
		.should_draw(should_draw),
		.trace_path(trace_path),
		.clear_screen(clear_screen),
		.px_x(_rd_x),
		.px_y(_rd_y),
		.wr_en(_wr_en),
		.wr_x(_wr_x),
		.wr_y(_wr_y),
		.byte_out(_wr_byte)
	);

	VgaBuffer _vga_buf (
		.clk(clk),
		.rd_x(_rd_x),
		.rd_y(_rd_y),
		.wr_en(_wr_en),
		.wr_x(_wr_x),
		.wr_y(_wr_y),
		.byte_in(_wr_byte),
		.byte_out(_rd_byte)
	);

	ByteToRgb _byte_to_rgb (
		.byte_in(_rd_byte),
		.r_out(_red),
		.g_out(_green),
		.b_out(_blue)
	);

	FreqDivider #(
		.DIV_BITS(`VGA_FREQ_DIV_BITS)
	) _freq_div (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.en(1),
		.div(`VGA_FREQ_DIV),
		.out(_vga_clk)
	);

	VgaController _vga_controller (
		.clk(clk),
		.reset(reset),
		.clk_en(_vga_clk),
		.r_in(_red),
		.g_in(_green),
		.b_in(_blue),
		.px_x(_rd_x),
		.px_y(_rd_y),
		.r_out(r_out),
		.g_out(g_out),
		.b_out(b_out),
		.h_sync(h_sync),
		.v_sync(v_sync)
	);

endmodule : MotorSignalsToVga
