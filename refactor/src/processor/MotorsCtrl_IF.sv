`include "processor/processor.svh"

import Servo_PKG::ServoPos_t;

/**
* Interface for controlling motors unit.
*
* :port pulse_num_x: Number of steps in x direction (steppers).
* :port pulse_num_y: Number of steps in y direction (steppers).
* :port servo_pos: Position of servo.
* :port trigger: Triggers movements.
* :port done: Movements done.
* :port rdy: ready to accept triggers.
*/
interface MotorsCtrl_IF ();

	logic [`STEPPER_PULSE_NUM_X_BITS-1:0] pulse_num_x;
	logic [`STEPPER_PULSE_NUM_Y_BITS-1:0] pulse_num_y;
	ServoPos_t servo_pos;
	logic trigger;
	logic done;
	logic rdy;

	modport master (
		output pulse_num_x,
		output pulse_num_y,
		output servo_pos,
		output trigger,
		input done,
		input rdy
	);

	modport slave (
		input pulse_num_x,
		input pulse_num_y,
		input servo_pos,
		input trigger,
		output done,
		output rdy
	);

endinterface : MotorsCtrl_IF
