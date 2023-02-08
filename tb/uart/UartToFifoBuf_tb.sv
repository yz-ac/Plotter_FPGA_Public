`include "tb/simulation.svh"
`include "common/common.svh"
`include "uart/uart.svh"

module UartToFifoBuf_tb;

	localparam CLKS_PER_BIT = `UART_CLKS_PER_BIT;
	localparam COLS = `BYTE_BITS;
	localparam ROWS = 244;

	wire clk;
	reg reset;
	reg data_in;
	wire wr_done;
	wire wr_rdy;
	wire is_full;
	wire wr_trigger;
	wire [`BYTE_BITS-1:0] data_out;

	int _ifd;
	byte _char;

	SimClock sim_clk (
		.out(clk)
	);

	FifoBuffer #(
		.ROWS(ROWS),
		.COLS(COLS)
	) fifo_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(0),
		.wr_trigger(wr_trigger),
		.wr_data(data_out),
		.rd_data(),
		.is_empty(),
		.is_full(is_full),
		.rd_done(),
		.rd_rdy(),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy)
	);

	UartToFifoBuf #(
		.CLKS_PER_BIT(CLKS_PER_BIT)
	) UUT (
		.clk(clk),
		.reset(reset),
		.data_in(data_in),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy),
		.is_full(is_full),
		.wr_trigger(wr_trigger),
		.data_out(data_out)
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

	always_ff @(posedge is_full) begin
		$writememh("tests/tests/UartToFifoBuf_tb.txt", fifo_buf._bram._mem);
		`STOP
	end // always_ff

	initial begin
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
	end // initial

endmodule : UartToFifoBuf_tb
