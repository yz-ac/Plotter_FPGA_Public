`include "tb/simulation.svh"
`include "motors/motors.svh"

import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;

module MotorsCtrl_tb;
	int fd;

	wire clk;
	reg reset;
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS)
	) intf ();
	wire out_x;
	wire dir_x;
	wire n_en_x;
	wire out_y;
	wire dir_y;
	wire n_en_y;
	wire out_servo;

	SimClock sim_clk (
		.out(clk)
	);

	MotorsCtrl UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.intf(intf.slave),
		.out_x(out_x),
		.dir_x(dir_x),
		.n_en_x(n_en_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.n_en_y(n_en_y),
		.out_servo(out_servo)
	);

	typedef enum {
		TB_TEST_1,
		TB_TEST_2,
		TB_BAD
	} MotorsCtrl_tb_test;

	MotorsCtrl_tb_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		intf.master.pulse_num_x <= -3;
		intf.master.pulse_num_y <= 2;
		intf.master.servo_pos <= SERVO_POS_DOWN;
		intf.master.trigger <= 1;
	end

	always_ff @(negedge intf.master.rdy) begin
		intf.master.trigger <= 0;
	end

	always_ff @(posedge intf.master.rdy) begin
		case (_test)
		TB_TEST_1: begin
			_test <= TB_TEST_2;
			intf.master.pulse_num_x <= 5;
			intf.master.pulse_num_y <= 1;
			intf.master.servo_pos <= SERVO_POS_UP;
			intf.master.trigger <= 1;
		end
		TB_TEST_2: begin
			`FCLOSE
			`STOP
		end
		default: begin
			_test <= TB_BAD;
			intf.master.pulse_num_x <= 0;
			intf.master.pulse_num_y <= 0;
			intf.master.servo_pos <= SERVO_POS_UP;
			intf.master.trigger <= 0;
		end
		endcase
	end

	always_ff @(posedge out_x) begin
		`FWRITE(("%t : X : %d : %d", $time, dir_x, out_servo))
	end

	always_ff @(posedge out_y) begin
		`FWRITE(("%t : Y : %d : %d", $time, dir_y, out_servo))
	end

	initial begin
		`FOPEN("tests/tests/MotorsCtrl_tb.txt")

		reset = 1;
		intf.master.pulse_num_x = 0;
		intf.master.pulse_num_y = 0;
		intf.master.servo_pos = SERVO_POS_UP;
		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : MotorsCtrl_tb
