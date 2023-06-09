`include "motors/motors.svh"

/**
* Module to control all motors.
*
* :param STEPPER_PULSE_NUM_X_FACTOR: Pulse number multiplier (for better motor resolution) in X direction.
* :param STEPPER_PULSE_NUM_Y_FACTOR: Pulse number multiplier (for better motor resolution) in Y direction.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :iface intf: Interface for controlling motors.
* :output out_x: Output to X stepper motor.
* :output dir_x: Direction output to X stepper motor.
* :output n_en_x: Enable signal for X driver (active low) to prevent idle current.
* :output out_y: Output to Y stepper motor.
* :output dir_y: Direction output to Y stepper motor.
* :output n_en_x: Enable signal for X driver (active low) to prevent idle current.
* :output out_servo: PWM output to servo.
*/
module MotorsCtrl #(
	parameter STEPPER_PULSE_NUM_X_FACTOR = `STEPPER_PULSE_NUM_X_FACTOR,
	parameter STEPPER_PULSE_NUM_Y_FACTOR = `STEPPER_PULSE_NUM_Y_FACTOR

)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	MotorsCtrl_IF intf,

	output logic out_x,
	output logic dir_x,
	output logic n_en_x,
	output logic out_y,
	output logic dir_y,
	output logic n_en_y,
	output logic out_servo
);

	wire _motors_done;
	wire _motors_rdy;
	wire _motors_trigger;

	wire _servo_trigger;
	wire _servo_done;
	wire _servo_rdy;

	wire _steppers_trigger;
	wire _steppers_done;
	wire _steppers_rdy;

	StepperCtrlXY_IF #(
		.PULSE_NUM_X_BITS(intf.PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(intf.PULSE_NUM_Y_BITS),
		.PULSE_WIDTH_BITS(`STEPPER_PULSE_WIDTH_BITS)
	) _intf_xy ();

	ServoCtrl_IF _intf_servo ();

	StepperCtrlXY #(
		.MULT_X(STEPPER_PULSE_NUM_X_FACTOR),
		.MULT_Y(STEPPER_PULSE_NUM_Y_FACTOR)
	) _xy_ctrl (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(_intf_xy.slave),
		.out_x(out_x),
		.dir_x(dir_x),
		.n_en_x(n_en_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.n_en_y(n_en_y)
	);

	ServoCtrl _servo_ctrl (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(_intf_servo.slave),
		.out(out_servo)
	);

	MotorsCtrl_InnerConnect _inner_connect (
		.motors_done(_motors_done),
		.motors_rdy(_motors_rdy),
		.servo_trigger(_servo_trigger),
		.steppers_trigger(_steppers_trigger),
		.intf_motors(intf),
		.intf_xy(_intf_xy.master),
		.intf_servo(_intf_servo.master),
		.motors_trigger(_motors_trigger),
		.servo_done(_servo_done),
		.servo_rdy(_servo_rdy),
		.steppers_done(_steppers_done),
		.steppers_rdy(_steppers_rdy)
	);

	MotorsCtrl_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.motors_trigger(_motors_trigger),
		.servo_done(_servo_done),
		.servo_rdy(_servo_rdy),
		.steppers_done(_steppers_done),
		.steppers_rdy(_steppers_rdy),
		.motors_done(_motors_done),
		.motors_rdy(_motors_rdy),
		.servo_trigger(_servo_trigger),
		.steppers_trigger(_steppers_trigger)
	);

endmodule : MotorsCtrl
