`include "common/common.svh"
`include "uart/uart.svh"
`include "motors/motors.svh"
`include "uart/uart.svh"
`include "plotter/plotter.svh"

import Op_PKG::Op_st;

/**
* Plotter top module.
*
* :input clk: System clock.
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
module PlotterTop (
	input logic clk,
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

	wire _uart_wr_trigger;
	wire _uart_wr_done;
	wire _uart_wr_rdy;
	wire _uart_is_full;
	wire [`BYTE_BITS-1:0] _uart_data;

	wire _parser_rd_trigger;
	wire _parser_rd_done;
	wire _parser_rd_rdy;
	wire _parser_is_empty;
	wire [`BYTE_BITS-1:0] _parser_rd_data;

	wire _parser_wr_trigger;
	wire _parser_wr_done;
	wire _parser_wr_rdy;
	wire _parser_is_full;
	Op_st _parser_op;
	wire [`OP_BITS-1:0] _parser_op_bits;

	wire _proc_rd_trigger;
	wire _proc_rd_done;
	wire _proc_rd_rdy;
	wire _proc_is_empty;
	wire [`OP_BITS-1:0] _proc_data;
	wire [`OP_BITS-1:0] _proc_op_bits;
	Op_st _proc_op;

	wire _proc_trigger;
	wire _proc_done;
	wire _proc_rdy;
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) _proc_motors_intf ();

	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) _motors_intf ();
	wire _out_x;
	wire _dir_x;
	wire _out_y;
	wire _dir_y;

	wire _should_draw;
	wire [`BYTE_BITS-1:0] _red;
	wire [`BYTE_BITS-1:0] _green;
	wire [`BYTE_BITS-1:0] _blue;

	UartToFifoBuf #(
		.CLKS_PER_BIT(`UART_CLKS_PER_BIT),
		.COUNTER_BITS(`UART_COUNTER_BITS),
		.DATA_SIZE(`UART_DATA_SIZE),
		.DATA_SIZE_BITS(`UART_DATA_SIZE_BITS)
	)  _uart_to_fifo (
		.clk(clk),
		.reset(reset),
		.data_in(uart_rx),
		.wr_done(_uart_wr_done),
		.wr_rdy(_uart_wr_rdy),
		.is_full(_uart_is_full),
		.wr_trigger(_uart_wr_trigger),
		.data_out(_uart_data)
	);

	FifoBuffer #(
		.ROWS(`PLOTTER_UART_TO_PARSER_BRAM_ROWS),
		.COLS(`BYTE_BITS)
	) _uart_to_parser_fifo_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(_parser_rd_trigger),
		.wr_trigger(_uart_wr_trigger),
		.wr_data(_uart_data),
		.rd_data(_parser_rd_data),
		.is_empty(_parser_is_empty),
		.is_full(_uart_is_full),
		.rd_done(_parser_rd_done),
		.rd_rdy(_parser_rd_rdy),
		.wr_done(_uart_wr_done),
		.wr_rdy(_uart_wr_rdy)
	);

	ParserTop _parser (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_done(_parser_rd_done),
		.rd_rdy(_parser_rd_rdy),
		.is_empty(_parser_is_empty),
		.char_in(_parser_rd_data),
		.wr_done(_parser_wr_done),
		.wr_rdy(_parser_wr_rdy),
		.is_full(_parser_is_full),
		.rd_trigger(_parser_rd_trigger),
		.wr_trigger(_parser_wr_trigger),
		.op(_parser_op)
	);

	OpToBits _parser_op_to_bits (
		.op(_parser_op),
		.op_bits(_parser_op_bits)
	);

	FifoBuffer #(
		.ROWS(`PLOTTER_PARSER_TO_PROCESSOR_BRAM_ROWS),
		.COLS(`OP_BITS)
	) _parser_to_processor_fifo_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(_proc_rd_trigger),
		.wr_trigger(_parser_wr_trigger),
		.wr_data(_parser_op_bits),
		.rd_data(_proc_data),
		.is_empty(_proc_is_empty),
		.is_full(_parser_is_full),
		.rd_done(_proc_rd_done),
		.rd_rdy(_proc_rd_rdy),
		.wr_done(_parser_wr_done),
		.wr_rdy(_parser_wr_rdy)
	);

	BramReader #(
		.DATA_BITS(`OP_BITS)
	) _bram_reader (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.is_empty(_proc_is_empty),
		.bram_done(_proc_rd_done),
		.bram_rdy(_proc_rd_rdy),
		.reader_done(_proc_done),
		.reader_rdy(_proc_rdy),
		.bram_data(_proc_data),
		.bram_trigger(_proc_rd_trigger),
		.reader_trigger(_proc_trigger),
		.reader_data(_proc_op_bits)
	);

	BitsToOp _proc_bits_to_op (
		.op_bits(_proc_op_bits),
		.op(_proc_op)
	);

	ProcessorTop _processor (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(_proc_op),
		.trigger(_proc_trigger),
		.motors_intf(_proc_motors_intf.master),
		.done(_proc_done),
		.rdy(_proc_rdy)
	);

	PlotterTop_InnerConnect _inner_connect (
		.proc_motors_intf(_proc_motors_intf.slave),
		.motors_intf(_motors_intf.master),
		.should_draw(_should_draw)
	);

	MotorsCtrl #(
		.STEPPER_PULSE_NUM_X_FACTOR(`STEPPER_PULSE_NUM_X_FACTOR),
		.STEPPER_PULSE_NUM_Y_FACTOR(`STEPPER_PULSE_NUM_Y_FACTOR)
	) _motors_ctrl (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.intf(_motors_intf.slave),
		.out_x(_out_x),
		.dir_x(_dir_x),
		.n_en_x(n_en_x),
		.out_y(_out_y),
		.dir_y(_dir_y),
		.n_en_y(n_en_y),
		.out_servo(out_servo)
	);

	MotorSignalsToVga #(
		.PULSE_NUM_X_FACTOR(`STEPPER_PULSE_NUM_X_FACTOR),
		.PULSE_NUM_Y_FACTOR(`STEPPER_PULSE_NUM_Y_FACTOR)
	) _motors_to_vga (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.motors_signal_x(_out_x),
		.motors_dir_x(_dir_x),
		.motors_signal_y(_out_y),
		.motors_dir_y(_dir_y),
		.should_draw(_should_draw),
		.r_out(_red),
		.g_out(_green),
		.b_out(_blue),
		.h_sync(vga_hs),
		.v_sync(vga_vs)
	);

	assign out_x = _out_x;
	assign dir_x = _dir_x;
	assign out_y = _out_y;
	assign dir_y = _dir_y;

	assign vga_r[3:2] = _red[7:6];
	assign vga_r[1:0] = _red[1:0];
	assign vga_g[3:2] = _green[7:6];
	assign vga_g[1:0] = _green[1:0];
	assign vga_b[3:2] = _blue[7:6];
	assign vga_b[1:0] = _blue[1:0];

endmodule : PlotterTop
