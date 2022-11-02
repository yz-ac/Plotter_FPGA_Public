`include "../common/common.svh"
`include "../processor/servo.svh"

import Servo::ServoPosition_t;

/**
* Controls the servo motor via PWM.
* Compatible with sg90 servo.
*
* :param PERIOD_BITS: Number of bits in the servo pwm period.
* :input clk: System clock.
* :input reset: Resets the module.
* :input pos: Servo motor position.
* :output out: PWM output for the servo.
*/
module ServoCtrl #(
	parameter PERIOD_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input Servo::ServoPosition_t pos,

	output logic out
);

	wire servo_clk_en;
	wire [PERIOD_BITS-1:0] duty_cycle;

	// Clk_en for servo pwm is separate to ensure timing according to datasheet.
	ClockEnabler #(
		.PERIOD_BITS(`SERVO_CLK_EN_BITS)
	) servo_clk_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(`SERVO_CLK_EN),
		.out(servo_clk_en)
	);

	Pwm #(
		.PERIOD_BITS(PERIOD_BITS)
	) servo_pwm (
		.clk(clk),
		.reset(reset),
		.clk_en(servo_clk_en),
		.period(`SERVO_PERIOD),
		.duty_cycle(duty_cycle),
		.out(out)
	);

	assign duty_cycle = (pos == Servo::SERVO_POS_UP) ? (`SERVO_DUTY_UP) : (`SERVO_DUTY_DOWN);

endmodule : ServoCtrl
