`include "tb/simulation.svh"
`include "common/common.svh"
`include "processor/processor.svh"

import Op_PKG::Op_st;

module BramReader_tb;
	int fd;

	localparam COLS = `OP_BITS;
	localparam ROWS = 314;
	localparam MAX_ROWS = ROWS;
	localparam PRELOADED_ROWS = ROWS;
	localparam DATA_BITS = COLS;
	localparam ADDR_BITS = $clog2(MAX_ROWS);
	localparam INIT_FILE = "data/circles.mem";

	wire clk;
	reg reset;
	wire sim_done;

	wire out_x;
	wire dir_x;
	wire out_y;
	wire dir_y;
	wire out_servo;

	Op_st op;
	wire proc_trigger;
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) motors_intf ();
	wire proc_done;
	wire proc_rdy;

	wire [ADDR_BITS-1:0] rd_addr;
	wire wr_en;
	wire [ADDR_BITS-1:0] wr_addr;
	wire [DATA_BITS-1:0] wr_data;
	wire [DATA_BITS-1:0] rd_data;

	wire rd_trigger;
	wire wr_trigger;
	wire is_full;
	wire rd_done;
	wire rd_rdy;
	wire wr_done;
	wire wr_rdy;

	wire [DATA_BITS-1:0] reader_data;

	SimClock sim_clk (
		.out(clk)
	);

	MotorsCtrl motors_ctrl (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.intf(motors_intf.slave),
		.out_x(out_x),
		.dir_x(dir_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.out_servo(out_servo)
	);

	ProcessorTop proc (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.trigger(proc_trigger),
		.motors_intf(motors_intf.master),
		.done(proc_done),
		.rdy(proc_rdy)
	);

	Bram #(
		.ROWS(ROWS),
		.COLS(COLS),
		.INIT_FILE(INIT_FILE)
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
		.PRELOADED_ROWS(PRELOADED_ROWS)
	) bram_ctrl (
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

	BramReader #(
		.DATA_BITS(DATA_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.is_empty(is_empty),
		.bram_done(rd_done),
		.bram_rdy(rd_rdy),
		.reader_done(proc_done),
		.reader_rdy(proc_rdy),
		.bram_data(rd_data),
		.bram_trigger(rd_trigger),
		.reader_trigger(proc_trigger),
		.reader_data(reader_data)
	);

	assign wr_trigger = 0;
	assign wr_data = 0;

	assign op.cmd = reader_data[63:56];
	assign op.arg_1 = reader_data[55:44];
	assign op.arg_2 = reader_data[43:32];
	assign op.arg_3 = reader_data[31:20];
	assign op.arg_4 = reader_data[19:8];
	assign op.flags = reader_data[7:0];

	assign sim_done = is_empty & proc_rdy & rd_rdy;

	always_ff @(posedge sim_done) begin
		`FCLOSE
		`STOP
	end

	always_ff @(posedge out_x) begin
		`FWRITE(("%t : X : %d : %d", $time, dir_x, motors_intf.servo_pos))
	end

	always_ff @(posedge out_y) begin
		`FWRITE(("%t : Y : %d : %d", $time, dir_y, motors_intf.servo_pos))
	end

	initial begin
		`FOPEN("tests/tests/BramReader_tb.txt")

		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : BramReader_tb
