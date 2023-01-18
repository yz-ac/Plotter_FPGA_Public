`include "motors/motors.svh"

import Servo_PKG::ServoDir_t;
import Servo_PKG::SERVO_DIR_UP;
import Servo_PKG::SERVO_DIR_DOWN;
import Servo_PKG::SERVO_DIR_STAY;

/**
* Converts servo movement signals to PWM on-time.
*
* :input dir: Servo direction.
* :output on_time: PWM on-time corresponding to specified direction.
*/
module ServoCtrl_DirToPwm (
	input ServoDir_t dir,
	output logic [`SERVO_PWM_BITS-1:0] on_time
);

	always_comb begin
	case (dir)
	SERVO_DIR_UP: begin
		on_time = `SERVO_PWM_UP;
	end
	SERVO_DIR_DOWN: begin
		on_time = `SERVO_PWM_DOWN;
	end
	SERVO_DIR_STAY: begin
		on_time = `SERVO_PWM_CENTER;
	end
	default: begin
		on_time = `SERVO_PWM_CENTER;
	end
	endcase
	end // always_comb

endmodule : ServoCtrl_DirToPwm
