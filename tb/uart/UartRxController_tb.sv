`include "tb/simulation.svh"
`include "common/common.svh"
`include "uart/uart.svh"

module UartRxController_tb;
	int fd;

	localparam CLKS_PER_BIT = `UART_CLKS_PER_BIT;

	wire clk;
	reg reset;
	reg data_in;
	wire [`BYTE_BITS-1:0] data_out;
	wire rx_done;

	int _ifd;
	byte _char;

	SimClock sim_clk (
		.out(clk)
	);

	UartRxController #(
		.CLKS_PER_BIT(CLKS_PER_BIT)
	) UUT (
		.clk(clk),
		.reset(reset),
		.data_in(data_in),
		.data_out(data_out),
		.rx_done(rx_done)
	);

	task __write_byte (
		input byte char_in
	);

		data_in <= 0;
		#(`CLOCK_PERIOD * CLKS_PER_BIT);

		for (int i = 0; i < 8; i++) begin
			data_in <= char_in[i];
			#(`CLOCK_PERIOD * CLKS_PER_BIT);
		end

		data_in <= 1;
		#(`CLOCK_PERIOD * CLKS_PER_BIT);

	endtask : __write_byte

	always_ff @(posedge rx_done) begin
		if (fd) begin
			$fwrite(fd, "%c", data_out);
		end
	end

	initial begin
		fd = $fopen("tests/tests/UartRxController_tb.txt");

		reset = 1;
		data_in = 1;
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

		`FCLOSE
		`STOP
	end // initial

endmodule : UartRxController_tb
