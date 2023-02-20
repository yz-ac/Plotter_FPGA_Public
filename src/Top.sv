/**
* Project Top.
*
* :input master_clk: FPGA clock (100MHz).
* :input reset: Resets the module.
* :input uart_rx: UART RX serial input.
* :output vga_r: VGA red channel.
* :output vga_g: VGA green channel.
* :output vga_b: VGA blue channel.
* :output vga_hs: VGA horizontal sync.
* :output vga_vs: VGA vertical sync.
* :output out_x: Motor X step signal.
* :output dir_x: Motor X direction signal.
* :output n_en_x: Motor X driver enable (active low).
* :output out_y: Motor Y step signal.
* :output dir_y: Motor Y direction signal.
* :output n_en_y: Motor Y driver enable (active low).
* :output out_servo: Servo PWM signal.
*/
module Top (
	input logic master_clk,
	input logic reset,

	input logic uart_rx,

	output logic [3:0] vga_r,
	output logic [3:0] vga_g,
	output logic [3:0] vga_b,
	output logic vga_hs,
	output logic vga_vs,

	output logic out_x,
	output logic dir_x,
	output logic n_en_x,
	output logic out_y,
	output logic dir_y,
	output logic n_en_y,
	output logic out_servo
);

	wire _clk_25;

	PlotterTop _plotter (
		.clk(_clk_25),
		.reset(reset),

		.uart_rx(uart_rx),

		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b),
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),

		.out_x(out_x),
		.dir_x(dir_x),
		.n_en_x(n_en_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.n_en_y(n_en_y),
		.out_servo(out_servo)
	);

`ifdef SIM_DEBUG

	assign _clk_25 = master_clk;

`else // SIM_DEBUG

	Mmcm #(
		.CLK_MULT(9.125),
		.CLK_DIV(36.500)
	) _mmcm (
		.clk_in(master_clk),
		.clk_out(_clk_25)
	);

`endif // SIM_DEBUG

endmodule : Top
