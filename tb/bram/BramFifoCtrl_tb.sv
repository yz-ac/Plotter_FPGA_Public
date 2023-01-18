`include "tb/simulation.svh"
`include "common/common.svh"

`define LOG() \
		`FWRITE(("time: %t, test: %d, rd_addr: %d, wr_addr: %d, wr_en: %d, rd_data: %d, wr_data: %d, is_full: %d, is_empty: %d", $time, _test, rd_addr, wr_addr, wr_en, rd_data, wr_data, is_full, is_empty))

module BramFifoCtrl_tb;
	int fd;

	localparam ROWS = 2;
	localparam COLS = `BYTE_BITS;
	localparam ADDR_BITS = $clog2(ROWS);
	localparam MAX_ROWS = ROWS;

	wire clk;
	reg reset;
	reg rd_trigger;
	reg wr_trigger;

	wire [ADDR_BITS-1:0] rd_addr;
	wire wr_en;
	wire [ADDR_BITS-1:0] wr_addr;
	wire is_empty;
	wire is_full;
	wire rd_done;
	wire rd_rdy;
	wire wr_done;
	wire wr_rdy;

	reg [COLS-1:0] wr_data;
	wire [COLS-1:0] rd_data;

	SimClock sim_clk (
		.out(clk)
	);

	Bram #(
		.ROWS(ROWS),
		.COLS(COLS)
	) bram (
		.clk(clk),
		.rd_addr(rd_addr),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.wr_data(wr_data),
		.rd_data(rd_data)
	);

	BramFifoCtrl #(
		.MAX_ROWS(MAX_ROWS),
		.PRELOADED_ROWS(0)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(rd_trigger),
		.wr_trigger(wr_trigger),
		.rd_addr(rd_addr),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.is_empty(is_empty),
		.is_full(is_full),
		.rd_done(rd_done),
		.rd_rdy(rd_rdy),
		.wr_done(wr_done),
		.wr_rdy(wr_rdy)
	);

	typedef enum {
		TB_TEST_1, // write
		TB_TEST_2, // write
		TB_TEST_3, // read
		TB_TEST_4, // write (should be cyclic)
		TB_TEST_5, // read
		TB_TEST_6, // read + write (read should happen)
		TB_TEST_7, // write
		TB_BAD
	} BramFifoCtrl_test;

	BramFifoCtrl_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		rd_trigger <= 0;
		wr_trigger <= 1;
		wr_data <= 1;
	end

	always_ff @(negedge rd_rdy) begin
		rd_trigger <= 0;
	end

	always_ff @(negedge wr_rdy) begin
		wr_trigger <= 0;
	end

	always_ff @(posedge rd_rdy or posedge wr_rdy) begin
		case (_test)
		TB_TEST_1: begin
			`LOG
			_test <= TB_TEST_2;
			rd_trigger <= 0;
			wr_trigger <= 1;
			wr_data <= 2;
		end
		TB_TEST_2: begin
			`LOG
			_test <= TB_TEST_3;
			rd_trigger <= 1;
			wr_trigger <= 0;
			wr_data <= 3;
		end
		TB_TEST_3: begin
			`LOG
			_test <= TB_TEST_4;
			rd_trigger <= 0;
			wr_trigger <= 1;
			wr_data <= 4;
		end
		TB_TEST_4: begin
			`LOG
			_test <= TB_TEST_5;
			rd_trigger <= 1;
			wr_trigger <= 0;
			wr_data <= 5;
		end
		TB_TEST_5: begin
			`LOG
			_test <= TB_TEST_6;
			rd_trigger <= 1;
			wr_trigger <= 1;
			wr_data <= 6;
		end
		TB_TEST_6: begin
			`LOG
			_test <= TB_TEST_7;
			rd_trigger <= 0;
			wr_trigger <= 1;
			wr_data <= 7;
		end
		TB_TEST_7: begin
			`LOG
			`FCLOSE
			`STOP
		end
		endcase
	end

	initial begin
		`FOPEN("tests/tests/BramFifoCtrl_tb.txt")

		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end

endmodule : BramFifoCtrl_tb
