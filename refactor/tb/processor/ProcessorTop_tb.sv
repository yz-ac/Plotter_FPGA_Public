`include "tb/simulation.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

module ProcessorTop_tb;

	int fd;

	wire clk;
	reg reset;
	Op_st op;
	reg trigger;

	wire out_x;
	wire dir_x;
	wire out_y;
	wire dir_y;
	wire out_servo;
	wire done;
	wire rdy;

	SimClock sim_clk (
		.out(clk)
	);

	ProcessorTop UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.trigger(trigger),
		
		.out_x(out_x),
		.dir_x(dir_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.out_servo(out_servo),
		.done(done),
		.rdy(rdy)
	);

	typedef enum {
		TB_TEST_1,
		TB_TEST_2,
		TB_TEST_3,
		TB_TEST_4,
		TB_TEST_5,
		TB_TEST_6,
		TB_TEST_7,
		TB_TEST_8,
		TB_TEST_9,
		TB_TEST_10,
		TB_TEST_11,
		TB_TEST_12,
		TB_TEST_13,
		TB_BAD
	} ProcessorTop_tb_test;

	ProcessorTop_tb_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		op.cmd <= OP_CMD_G00;
		op.arg_1 <= 100;
		op.arg_2 <= 100;
		trigger <= 1;
	end

	always_ff @(negedge rdy) begin
		trigger <= 0;
	end

	always_ff @(posedge rdy) begin
		case (_test)
		TB_TEST_1: begin
			_test <= TB_TEST_2;
			op.cmd <= OP_CMD_G90;
			trigger <= 1;
		end
		TB_TEST_2: begin
			_test <= TB_TEST_3;
			op.cmd <= OP_CMD_G02;
			op.arg_1 <= 100;
			op.arg_2 <= 100;
			op.arg_3 <= 0;
			op.arg_4 <= -20;
			trigger = 1;
		end
		TB_TEST_3: begin
			_test <= TB_TEST_4;
			op.cmd <= OP_CMD_G00;
			op.arg_1 <= 80;
			op.arg_2 <= 100;
			trigger = 1;
		end
		TB_TEST_4: begin
			_test <= TB_TEST_5;
			op.cmd <= OP_CMD_G01;
			op.arg_1 <= 120;
			op.arg_2 <= 100;
			trigger = 1;
		end
		TB_TEST_5: begin
			_test <= TB_TEST_6;
			op.cmd <= OP_CMD_G01;
			op.arg_1 <= 120;
			op.arg_2 <= 60;
			trigger = 1;
		end
		TB_TEST_6: begin
			_test <= TB_TEST_7;
			op.cmd <= OP_CMD_G01;
			op.arg_1 <= 80;
			op.arg_2 <= 60;
			trigger = 1;
		end
		TB_TEST_7: begin
			_test <= TB_TEST_8;
			op.cmd <= OP_CMD_G01;
			op.arg_1 <= 80;
			op.arg_2 <= 100;
			trigger = 1;
		end
		TB_TEST_8: begin
			_test <= TB_TEST_9;
			op.cmd <= OP_CMD_G02;
			op.arg_1 <= 120;
			op.arg_2 <= 100;
			op.arg_3 <= 20;
			op.arg_4 <= 0;
			trigger = 1;
		end
		TB_TEST_9: begin
			_test <= TB_TEST_10;
			op.cmd <= OP_CMD_G00;
			op.arg_1 <= 80;
			op.arg_2 <= 100;
			trigger = 1;
		end
		TB_TEST_10: begin
			_test <= TB_TEST_11;
			op.cmd <= OP_CMD_G03;
			op.arg_1 <= 80;
			op.arg_2 <= 60;
			op.arg_3 <= 0;
			op.arg_4 <= -20;
			trigger = 1;
		end
		TB_TEST_11: begin
			_test <= TB_TEST_12;
			op.cmd <= OP_CMD_G00;
			op.arg_1 <= 200;
			op.arg_2 <= 200;
			trigger = 1;
		end
		TB_TEST_12: begin
			_test <= TB_TEST_13;
			op.cmd <= OP_CMD_G02;
			op.arg_1 <= 200;
			op.arg_2 <= 190;
			op.arg_3 <= -100;
			op.arg_4 <= -1;
			trigger = 1;
		end
		TB_TEST_13: begin
			`FCLOSE
			`STOP
		end
		default: begin
			_test <= TB_BAD;
			op <= {0, 0, 0, 0, 0, 0};
			trigger <= 0;
		end
		endcase
	end

	always_ff @(posedge out_x) begin
		`FWRITE(("%t : X : %d : %d", $time, dir_x, UUT._large_motors_intf.slave.servo_pos))
	end

	always_ff @(posedge out_y) begin
		`FWRITE(("%t : Y : %d : %d", $time, dir_y, UUT._large_motors_intf.slave.servo_pos))
	end

	initial begin
		`FOPEN("tests/tests/ProcessorTop_tb.txt")
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : ProcessorTop_tb
