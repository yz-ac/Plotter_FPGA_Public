`include "common/common.svh"
`include "vga/vga.svh"

/**
* VGA controller.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Pixel clock (25MHz for 640x480x60Hz).
* :input r_in: Red value from FPGA side.
* :input g_in: Green value from FPGA side.
* :input b_in: Blue value from FPGA side.
* :output px_x: Current X coordinate of pixel being read.
* :output px_y: Current Y coordinate of pixel being read.
* :output r_out: Red value to monitor side.
* :output g_out: Green value to monitor side.
* :output b_out: Blue value to monitor side.
* :output h_sync: Horizontal sync signal to monitor.
* :output v_sync: Vertical sync signal to monitor.
*/
module VgaController (
	input logic clk,
	input logic reset,
	input logic clk_en,

	input logic [`BYTE_BITS-1:0] r_in,
	input logic [`BYTE_BITS-1:0] g_in,
	input logic [`BYTE_BITS-1:0] b_in,
	output logic [`VGA_H_BITS-1:0] px_x,
	output logic [`VGA_V_BITS-1:0] px_y,

	output logic [`BYTE_BITS-1:0] r_out,
	output logic [`BYTE_BITS-1:0] g_out,
	output logic [`BYTE_BITS-1:0] b_out,
	output logic h_sync,
	output logic v_sync
);

	localparam H_BLANK = `VGA_H_FRONT + `VGA_H_SYNC + `VGA_H_BACK;
	localparam H_TOTAL = H_BLANK + `VGA_H_ACTIVE;
	localparam V_BLANK = `VGA_V_FRONT + `VGA_V_SYNC + `VGA_V_BACK;
	localparam V_TOTAL = V_BLANK + `VGA_V_ACTIVE;

	reg [`VGA_H_BITS-1:0] _h_counter;
	reg [`VGA_V_BITS-1:0] _v_counter;
	wire _h_sync;
	wire _v_sync;

	assign r_out = r_in;
	assign g_out = g_in;
	assign b_out = b_in;
	assign px_x = ((_h_counter >= H_BLANK) & (_v_counter >= V_BLANK)) ? (_h_counter - H_BLANK) : (0);
	assign px_y = (_v_counter >= V_BLANK) ? (_v_counter - V_BLANK) : (0);

	assign h_sync = _h_sync ^ `VGA_HS_POLARITY;
	assign v_sync = _v_sync ^ `VGA_VS_POLARITY;

	assign _h_sync = (_h_counter >= `VGA_H_FRONT) & (_h_counter < `VGA_H_FRONT + `VGA_H_SYNC);
	assign _v_sync = (_v_counter >= `VGA_V_FRONT) & (_v_counter < `VGA_V_FRONT + `VGA_V_SYNC);

	always_ff @(posedge clk) begin
		if (reset) begin
			_h_counter <= 0;
			_v_counter <= 0;
		end
		else if (clk_en) begin
			_h_counter <= _h_counter + 1;
			_v_counter <= _v_counter;
			if (_h_counter == H_TOTAL - 1) begin
				_h_counter <= 0;
				_v_counter <= _v_counter + 1;
				if (_v_counter == V_TOTAL - 1) begin
					_v_counter <= 0;
				end
			end
		end
		else begin
			_h_counter <= _h_counter;
			_v_counter <= _v_counter;
		end
	end // always_ff

endmodule : VgaController
