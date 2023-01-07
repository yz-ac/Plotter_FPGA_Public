`include "tb/simulation.svh"
`include "processor/processor.svh"

import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;
import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

`define LOG() \
		`FWRITE(("time: %t, cmd: %d, trigger: %d, pulse_num_x: %d, pulse_num_y: %d, new_x: %d, new_y: %d", $time, op.cmd, motors_intf.slave.trigger, motors_intf.slave.pulse_num_x, motors_intf.slave.pulse_num_y, pos_update_intf.slave.new_x, pos_update_intf.slave.new_y))

module OpHandlerOutputChooser_tb;
	int fd;

	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS)
	) lin_motors_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS)
	) circ_motors_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS)
	) dummy_motors_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS)
	) motors_intf ();

	PositionUpdate_IF lin_pos_update_intf();
	PositionUpdate_IF circ_pos_update_intf();
	PositionUpdate_IF dummy_pos_update_intf();
	PositionUpdate_IF pos_update_intf();

	Op_st op;

	OpHandlerOutputChooser UUT (
		.op(op),
		.lin_motors_intf_in(lin_motors_intf.slave),
		.circ_motors_intf_in(circ_motors_intf.slave),
		.dummy_motors_intf_in(dummy_motors_intf.slave),
		.lin_pos_update_intf_in(lin_pos_update_intf.slave),
		.circ_pos_update_intf_in(circ_pos_update_intf.slave),
		.dummy_pos_update_intf_in(dummy_pos_update_intf.slave),
		.motors_intf_out(motors_intf.master),
		.pos_update_intf_out(pos_update_intf.master)
	);

	initial begin
		`FOPEN("tests/tests/OpHandlerOutputChooser_tb.txt")

		lin_motors_intf.master.pulse_num_x = 1;
		lin_motors_intf.master.pulse_num_y = 1;
		lin_motors_intf.master.servo_pos = SERVO_POS_UP;
		lin_motors_intf.master.trigger = 1;

		circ_motors_intf.master.pulse_num_x = 2;
		circ_motors_intf.master.pulse_num_y = 2;
		circ_motors_intf.master.servo_pos = SERVO_POS_DOWN;
		circ_motors_intf.master.trigger = 0;

		dummy_motors_intf.master.pulse_num_x = 3;
		dummy_motors_intf.master.pulse_num_y = 3;
		dummy_motors_intf.master.servo_pos = SERVO_POS_UP;
		dummy_motors_intf.master.trigger = 1;

		lin_pos_update_intf.master.new_x = 1;
		lin_pos_update_intf.master.new_y = 1;
		lin_pos_update_intf.master.update = 1;

		circ_pos_update_intf.master.new_x = 2;
		circ_pos_update_intf.master.new_y = 2;
		circ_pos_update_intf.master.update = 0;

		dummy_pos_update_intf.master.new_x = 3;
		dummy_pos_update_intf.master.new_y = 3;
		dummy_pos_update_intf.master.update = 1;

		op = {OP_CMD_G00, 0, 0, 0, 0, 0};
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G02;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G90;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G01;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G03;
		#(`CLOCK_PERIOD * 2);
		`LOG

		op.cmd = OP_CMD_G91;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : OpHandlerOutputChooser_tb
