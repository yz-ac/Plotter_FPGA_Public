`include "tb/simulation.svh"
`include "vga/vga.svh"
`include "uart/uart.svh"

module PlotterTop_tb;
	int fd;

	localparam CLKS_PER_BIT = `UART_CLKS_PER_BIT;

	wire clk;
	reg reset;
	reg uart_rx;
	reg trace_path;
	reg clear_screen;
	wire [3:0] vga_r;
	wire [3:0] vga_g;
	wire [3:0] vga_b;
	wire vga_hs;
	wire vga_vs;
	wire out_x;
	wire dir_x;
	wire n_en_x;
	wire out_y;
	wire dir_y;
	wire n_en_y;
	wire out_servo;

	int _ifd;
	byte _char;
	reg _done_tx;
	reg _last_frame;
	reg [`VGA_H_BITS-1:0] _last_x;
	reg [`VGA_V_BITS-1:0] _last_y;

	SimClock sim_clk (
		.out(clk)
	);

	PlotterTop UUT (
		.clk(clk),
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

	task __write_byte (
		input byte char_in
	);

		uart_rx <= 0;
		#(`CLOCK_PERIOD * CLKS_PER_BIT);

		for (int i = 0; i < 8; i++) begin
			uart_rx <= char_in[i];
			#(`CLOCK_PERIOD * CLKS_PER_BIT);
		end

		uart_rx <= 1;
		#(`CLOCK_PERIOD * CLKS_PER_BIT);

	endtask : __write_byte

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_x <= -1;
			_last_y <= -1;
			_last_frame <= 0;
		end
		else begin
			if ((_last_x != UUT._motors_to_vga._rd_x) | (_last_y != UUT._motors_to_vga._rd_y)) begin
				_last_x <= UUT._motors_to_vga._rd_x;
				_last_y <= UUT._motors_to_vga._rd_y;
				if (fd) begin
					$fwrite(fd, "%c%c%c", {8{vga_r[0]}}, {8{vga_g[0]}}, {8{vga_b[0]}});
				end
			end

			// Everyone finished
			if ((_last_y != UUT._motors_to_vga._rd_y) & (UUT._motors_to_vga._rd_y == 0) & UUT._processor.done & UUT._bram_reader.is_empty & _done_tx) begin
				_last_frame <= 1;
				if (_last_frame) begin
					`FCLOSE
					`STOP
				end
			end
		end
	end

	initial begin
		fd = $fopen("tests/tests/PlotterTop_tb.txt", "wb");

		trace_path = 0;
		clear_screen = 0;
		reset = 1;
		_done_tx = 0;
		uart_rx = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;

		_ifd = $fopen("data/simple.ngc", "rb");

		if (_ifd) begin
			while (!$feof(_ifd)) begin
				if (1 != $fread(_char, _ifd)) begin
					break;
				end

				__write_byte(_char);
			end

			$fclose(_ifd);
		end

		_done_tx = 1;

	end // initial

endmodule : PlotterTop_tb
