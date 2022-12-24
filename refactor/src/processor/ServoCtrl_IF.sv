import Servo_P::ServoPos_t;

interface ServoCtrl_IF;

	logic trigger;
	Servo_P::ServoPos_t pos;
	logic done;

	modport master (
		output trigger,
		output pos,
		input done
	);

	modport slave (
		input trigger,
		input pos,
		output done
	);

endinterface : ServoCtrl_IF
