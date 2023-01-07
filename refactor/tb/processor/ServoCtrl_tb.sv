`include "tb/simulation.svh"
`include "processor/processor.svh"

import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;

module ServoCtrl_tb;
	int fd;

	wire clk;
	reg reset;
	ServoCtrl_IF intf();
	wire out;

	SimClock sim_clk (
		.out(clk)
	);

	ServoCtrl UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.intf(intf.slave),
		.out(out)
	);

	typedef enum {
		TB_BAD,
		TB_TEST_1,
		TB_TEST_2,
		TB_TEST_3,
		TB_TEST_4
	} ServoCtrl_tb_test;

	ServoCtrl_tb_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		intf.master.pos <= SERVO_POS_UP;
		intf.master.trigger <= 1;
	end

	always_ff @(negedge intf.master.rdy) begin
		intf.master.trigger <= 0;
	end

	always_ff @(posedge intf.master.rdy) begin
		case (_test)
			TB_TEST_1: begin
				#(`CLOCK_PERIOD * `SERVO_TIMER_COUNT);
				_test <= TB_TEST_2;
				intf.master.trigger <= 1;
				intf.master.pos <= SERVO_POS_DOWN;
			end
			TB_TEST_2: begin
				_test <= TB_TEST_3;
				intf.master.trigger <= 1;
				intf.master.pos <= SERVO_POS_DOWN;
			end
			TB_TEST_3: begin
				#(`CLOCK_PERIOD * `SERVO_TIMER_COUNT);
				_test <= TB_TEST_4;
				intf.master.trigger <= 1;
				intf.master.pos <= SERVO_POS_UP;
			end
			TB_TEST_4: begin
				`FCLOSE
				`STOP
			end
			default: begin
				_test <= TB_BAD;
				intf.master.trigger <= 0;
				intf.master.pos <= SERVO_POS_UP;
			end
		endcase
	end

	always_ff @(posedge out) begin
		`FWRITE(("time: %t, test: %d, pos: %d", $time, _test, intf.pos))
	end

	initial begin
		`FOPEN("tests/tests/ServoCtrl_tb.txt")

		reset = 1;
		intf.master.trigger = 0;
		intf.master.pos = SERVO_POS_UP;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : ServoCtrl_tb
