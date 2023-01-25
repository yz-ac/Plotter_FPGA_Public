`include "tb/simulation.svh"
`include "processor/processor.svh"

import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

module CircularOpHandler_tb;

	int fd;

	wire clk;
	reg reset;
	Op_st op;
	OpHandler_IF handler_intf ();
	PositionState_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) state_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) update_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) motors_intf ();

	wire out_x;
	wire dir_x;
	wire out_y;
	wire dir_y;
	wire out_servo;

	SimClock sim_clk (
		.out(clk)
	);

	PositionKeeper pos_keeper (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.update_intf(update_intf.slave),
		.state_intf(state_intf.master)
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

	CircularOpHandler UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.op(op),
		.handler_intf(handler_intf.slave),
		.state_intf(state_intf.slave),
		.update_intf(update_intf.master),
		.motors_intf(motors_intf.master)
	);

	typedef enum {
		TB_TEST_1,
		TB_TEST_2,
		TB_TEST_3,
		TB_BAD
	} CircularOpHandler_tb_test;

	CircularOpHandler_tb_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		op.cmd <= OP_CMD_G02;
		op.arg_1 <= 50;
		op.arg_2 <= 50;
		op.arg_3 <= 50;
		op.arg_4 <= 0;
		op.flags <= 1;
		handler_intf.master.trigger <= 1;
	end

	always_ff @(negedge handler_intf.master.rdy) begin
		handler_intf.master.trigger <= 0;
	end

	always_ff @(posedge handler_intf.master.rdy) begin
		case (_test)
		TB_TEST_1: begin
			_test <= TB_TEST_2;
			op.cmd <= OP_CMD_G03;
			op.arg_1 <= 0;
			op.arg_2 <= 100;
			op.arg_3 <= -50;
			op.arg_4 <= 0;
			op.flags <= 1;
			handler_intf.master.trigger <= 1;
		end
		TB_TEST_2: begin
			_test <= TB_TEST_3;
			op.cmd <= OP_CMD_G91;
			#(`CLOCK_PERIOD * 10);
			op.cmd <= OP_CMD_G02;
			op.arg_1 <= 100;
			op.arg_2 <= -100;
			op.arg_3 <= 0;
			op.arg_4 <= -100;
			op.flags <= 1;
			handler_intf.master.trigger <= 1;
		end
		TB_TEST_3: begin
			`FCLOSE
			`STOP
		end
		default: begin
			_test <= TB_BAD;
			op <= {0, 0, 0, 0, 0, 0};
			handler_intf.master.trigger <= 0;
		end
		endcase
	end

	always_ff @(posedge out_x) begin
		`FWRITE(("%t : X : %d : %d", $time, dir_x, motors_intf.slave.servo_pos))
	end

	always_ff @(posedge out_y) begin
		`FWRITE(("%t : Y : %d : %d", $time, dir_y, motors_intf.slave.servo_pos))
	end

	initial begin
		`FOPEN("tests/tests/CircularOpHandler_tb.txt")
		reset = 1;
		handler_intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end // initial

endmodule : CircularOpHandler_tb
