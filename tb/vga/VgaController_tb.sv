`include "tb/simulation.svh"
`include "common/common.svh"
`include "vga/vga.svh"

module VgaController_tb;
	int fd;

	wire clk;
	reg reset;
	wire clk_en;
	reg [`BYTE_BITS-1:0] r_in;
	reg [`BYTE_BITS-1:0] g_in;
	reg [`BYTE_BITS-1:0] b_in;
	wire [`VGA_H_BITS-1:0] px_x;
	wire [`VGA_V_BITS-1:0] px_y;
	wire [`BYTE_BITS-1:0] r_out;
	wire [`BYTE_BITS-1:0] g_out;
	wire [`BYTE_BITS-1:0] b_out;
	wire h_sync;
	wire v_sync;

	SimClock sim_clk (
		.out(clk)
	);

	FreqDivider #(
		.DIV_BITS(`VGA_FREQ_DIV_BITS)
	) px_clk (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.en(1),
		.div(`VGA_FREQ_DIV),
		.out(clk_en)
	);

	VgaController UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.r_in(r_in),
		.g_in(g_in),
		.b_in(b_in),
		.px_x(px_x),
		.px_y(px_y),
		.r_out(r_out),
		.g_out(g_out),
		.b_out(b_out),
		.h_sync(h_sync),
		.v_sync(v_sync)
	);

	reg [`VGA_H_BITS-1:0] _last_px_x;
	reg [`VGA_V_BITS-1:0] _last_px_y;

	assign r_in = px_x[`BYTE_BITS-1:0];
	assign g_in = px_y[`BYTE_BITS-1:0];
	assign b_in = 'hff - r_in - g_in;

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_px_x <= -1;
			_last_px_y <= -1;
		end
		else if (clk_en) begin
			_last_px_x <= _last_px_x;
			_last_px_y <= _last_px_y;
			if ((_last_px_x != px_x) | (_last_px_y != px_y)) begin
				_last_px_x <= px_x;
				_last_px_y <= px_y;
				if (fd) begin
					$fwrite(fd, "%c%c%c", r_out, g_out, b_out);
				end
				if ((_last_px_x == `VGA_H_ACTIVE - 1) & (_last_px_y == `VGA_V_ACTIVE - 1)) begin
					`FCLOSE
					`STOP
				end
			end
		end
		else begin
			_last_px_x <= _last_px_x;
			_last_px_y <= _last_px_y;
		end
	end

	initial begin
		fd = $fopen("tests/tests/VgaController_tb.txt", "wb");

		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;

	end // initial

endmodule : VgaController_tb
