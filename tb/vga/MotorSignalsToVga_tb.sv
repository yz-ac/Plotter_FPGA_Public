`include "tb/simulation.svh"
`include "common/common.svh"
`include "motors/motors.svh"
`include "vga/vga.svh"

import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;

module MotorSignalsToVga_tb;
	int fd;

	localparam STEPPER_PULSE_NUM_X_FACTOR = 8;
	localparam STEPPER_PULSE_NUM_Y_FACTOR = 8;

	wire clk;
	reg reset;
	wire motors_signal_x;
	wire motors_dir_x;
	wire motors_signal_y;
	wire motors_dir_y;
	wire should_draw;
	reg trace_path;
	reg clear_screen;
	wire [`BYTE_BITS-1:0] r_out;
	wire [`BYTE_BITS-1:0] g_out;
	wire [`BYTE_BITS-1:0] b_out;
	wire h_sync;
	wire v_sync;

	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) motors_intf ();

	SimClock sim_clk (
		.out(clk)
	);

	MotorsCtrl #(
		.STEPPER_PULSE_NUM_X_FACTOR(STEPPER_PULSE_NUM_X_FACTOR),
		.STEPPER_PULSE_NUM_Y_FACTOR(STEPPER_PULSE_NUM_Y_FACTOR)
	) motors_ctrl (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.intf(motors_intf.slave),
		.out_x(motors_signal_x),
		.dir_x(motors_dir_x),
		.n_en_x(),
		.out_y(motors_signal_y),
		.dir_y(motors_dir_y),
		.n_en_y(),
		.out_servo()
	);

	MotorSignalsToVga #(
		.PULSE_NUM_X_FACTOR(STEPPER_PULSE_NUM_X_FACTOR),
		.PULSE_NUM_Y_FACTOR(STEPPER_PULSE_NUM_Y_FACTOR)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.motors_signal_x(motors_signal_x),
		.motors_dir_x(motors_dir_x),
		.motors_signal_y(motors_signal_y),
		.motors_dir_y(motors_dir_y),
		.should_draw(should_draw),
		.r_out(r_out),
		.g_out(g_out),
		.b_out(b_out),
		.h_sync(h_sync),
		.v_sync(v_sync)
	);

	assign should_draw = (motors_intf.slave.servo_pos == SERVO_POS_DOWN) ? 1 : 0;

	typedef enum {
		TB_TEST_1,
		TB_TEST_2,
		TB_TEST_3,
		TB_BAD
	} MotorSignalsToVga_tb_test;

	MotorSignalsToVga_tb_test _test;
	reg _end_sim;

	always_ff @(negedge reset) begin
		_end_sim <= 0;
		_test <= TB_TEST_1;
		motors_intf.master.pulse_num_x <= 50;
		motors_intf.master.pulse_num_y <= 50;
		motors_intf.master.servo_pos = SERVO_POS_DOWN;
		motors_intf.master.trigger <= 1;
	end

	always_ff @(negedge motors_intf.master.rdy) begin
		motors_intf.master.trigger <= 0;
	end

	always_ff @(posedge motors_intf.master.rdy) begin
		case (_test)
		TB_TEST_1: begin
			_test <= TB_TEST_2;
			motors_intf.master.pulse_num_x <= 50;
			motors_intf.master.pulse_num_y <= 20;
			motors_intf.master.servo_pos <= SERVO_POS_DOWN;
			motors_intf.master.trigger <= 1;
		end
		TB_TEST_2: begin
			_test <= TB_TEST_3;
			motors_intf.master.pulse_num_x <= 20;
			motors_intf.master.pulse_num_y <= -50;
			motors_intf.master.servo_pos <= SERVO_POS_DOWN;
			motors_intf.master.trigger <= 1;
		end
		TB_TEST_3: begin
			_end_sim <= 1;
		end
		endcase
	end

	reg [`VGA_H_BITS-1:0] _last_x;
	reg [`VGA_V_BITS-1:0] _last_y;

	always_ff @(posedge clk) begin
		if (reset) begin
			_last_x <= -1;
			_last_y <= -1;
		end
		else begin
			if ((_last_x != UUT._rd_x) | (_last_y != UUT._rd_y)) begin
				_last_x <= UUT._rd_x;
				_last_y <= UUT._rd_y;
				if (fd) begin
					$fwrite(fd, "%c%c%c", r_out, g_out, b_out);
				end
			end

			if ((_last_y != UUT._rd_y) & (UUT._rd_y == 0) & _end_sim) begin
				`FCLOSE
				`STOP
			end
		end
	end

	initial begin
		fd = $fopen("tests/tests/MotorSignalsToVga_tb.txt", "wb");

		trace_path = 0;
		clear_screen = 0;
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : MotorSignalsToVga_tb
