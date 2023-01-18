`include "motors/motors.svh"

import Servo_PKG::ServoDir_t;

/**
* Module for controlling modified continuous servo.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :iface intf: Interface for controlling the servo.
* :output out: PWM output for servo.
*/
module ServoCtrl (
	input logic clk,
	input logic reset,
	input logic clk_en,
	ServoCtrl_IF intf,
	output logic out
);

	wire [`SERVO_PWM_BITS-1:0] _on_time;
	ServoDir_t _dir;
	wire _timer_trigger;
	wire _timer_done;
	wire _timer_rdy;

	Pwm #(
		.PERIOD_BITS(`SERVO_PWM_BITS)
	) _pwm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.period(`SERVO_PWM_PERIOD),
		.on_time(_on_time),
		.out(out)
	);

	ServoCtrl_DirToPwm _dir_to_pwm (
		.dir(_dir),
		.on_time(_on_time)
	);

	TriggeredTimer #(
		.TIMER_BITS(`SERVO_TIMER_BITS)
	) _timer (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.en(1),
		.count(`SERVO_TIMER_COUNT),
		.trigger(_timer_trigger),
		.done(_timer_done),
		.rdy(_timer_rdy)
	);

	ServoCtrl_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(intf.trigger),
		.timer_done(_timer_done),
		.timer_rdy(_timer_rdy),
		.servo_pos(intf.pos),
		.timer_trigger(_timer_trigger),
		.servo_dir(_dir),
		.done(intf.done),
		.rdy(intf.rdy)
	);

endmodule : ServoCtrl
