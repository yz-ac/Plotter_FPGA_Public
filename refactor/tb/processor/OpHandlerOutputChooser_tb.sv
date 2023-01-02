`include "tb/simulation.svh"

import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;
import Op_PKG::Op_st;
import Op_PKG::OP_CMD_G00;
import Op_PKG::OP_CMD_G01;
import Op_PKG::OP_CMD_G02;
import Op_PKG::OP_CMD_G03;
import Op_PKG::OP_CMD_M05;
import Op_PKG::OP_CMD_G90;
import Op_PKG::OP_CMD_G91;

module OpHandlerOutputChooser_tb;

	MotorsCtrl_IF lin_intf ();
	MotorsCtrl_IF circ_intf ();
	MotorsCtrl_IF dummy_intf ();
	MotorsCtrl_IF motors_intf ();

	Op_st op;

	OpHandlerOutputChooser UUT (
		.op(op),
		.lin_intf_in(lin_intf.slave),
		.circ_intf_in(circ_intf.slave),
		.dummy_intf_in(dummy_intf.slave),
		.motors_intf_out(motors_intf.master)
	);

	initial begin
		lin_intf.master.pulse_num_x = 1;
		lin_intf.master.pulse_num_y = 1;
		lin_intf.master.servo_pos = SERVO_POS_UP;
		lin_intf.master.trigger = 1;

		circ_intf.master.pulse_num_x = 2;
		circ_intf.master.pulse_num_y = 2;
		circ_intf.master.servo_pos = SERVO_POS_DOWN;
		circ_intf.master.trigger = 0;

		dummy_intf.master.pulse_num_x = 3;
		dummy_intf.master.pulse_num_y = 3;
		dummy_intf.master.servo_pos = SERVO_POS_UP;
		dummy_intf.master.trigger = 1;

		op = {OP_CMD_M05, 0, 0, 0, 0, 0};
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G00;
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G02;
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G90;
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G01;
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G03;
		#(`CLOCK_PERIOD * 2);

		op.cmd = OP_CMD_G91;
		#(`CLOCK_PERIOD * 2);

		$stop;
	end // initial

endmodule : OpHandlerOutputChooser_tb
