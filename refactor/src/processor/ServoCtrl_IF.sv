import Servo_PKG::ServoPos_t;

/**
* Interface for controlling the modified servo.
*
* :port pos: Servo position.
* :port trigger: Triggers servo logic.
* :port done: Is logic done.
* :port rdy: Is ready to accept new triggers.
*/
interface ServoCtrl_IF ();

	ServoPos_t pos;
	logic trigger;
	logic done;
	logic rdy;

	modport master (
		output pos,
		output trigger,
		input done,
		input rdy
	);

	modport slave (
		input pos,
		input trigger,
		output done,
		output rdy
	);

endinterface : ServoCtrl_IF
