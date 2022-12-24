`include "processor/processor.svh"

import Servo_P::ServoMov_t;

module ServoMovToPwm (
	input Servo_P::ServoMov_t mov,
	output logic [`SERVO_PWM_BITS-1:0] on_time
);

	always_comb begin
		case (mov)
		Servo_P::SERVO_MOV_UP: begin
			on_time = `SERVO_PWM_UP;
		end
		Servo_P::SERVO_MOV_CENTER: begin
			on_time = `SERVO_PWM_CENTER;
		end
		Servo_P::SERVO_MOV_DOWN: begin
			on_time = `SERVO_PWM_DOWN;
		end
		default: begin
			on_time = `SERVO_PWM_CENTER;
		end
		endcase
	end // always_comb

endmodule : ServoMovToPwm
