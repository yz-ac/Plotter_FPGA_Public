`include "processor/processor.svh"

/**
* Inner connections between motors interfaces.
*
* :input motors_done: Is motors control logic done.
* :input motors_rdy: Is motors control logic ready to accept triggers.
* :input servo_trigger: Trigger for servo logic.
* :input steppers_trigger: Trigger for steppers logic.
* :iface intf_motors: MotorsCtrl interface.
* :iface intf_xy: Interface to XY steppers control.
* :iface intf_servo: Interface to servo control.
* :output servo_done: Is servo logic done.
* :output servo_rdy: Is servo logic ready to accept triggers.
* :output steppers_done: Is steppers logic done.
* :output steppers_rdy: Is steppers logic ready to accept triggers.
*/
module MotorsCtrl_InnerConnect (
	input logic motors_done,
	input logic motors_rdy,
	input logic servo_trigger,
	input logic steppers_trigger,
	MotorsCtrl_IF intf_motors,
	StepperCtrlXY_IF intf_xy,
	ServoCtrl_IF intf_servo,
	output logic servo_done,
	output logic servo_rdy,
	output logic steppers_done,
	output logic steppers_rdy
);

	assign intf_xy.pulse_num_x = intf_motors.pulse_num_x;
	assign intf_xy.pulse_num_y = intf_motors.pulse_num_y;
	assign intf_xy.pulse_width = `STEPPER_PULSE_WIDTH;
	assign intf_xy.trigger = steppers_trigger;

	assign intf_servo.pos = intf_motors.servo_pos;
	assign intf_servo.trigger = servo_trigger;

	assign intf_motors.done = motors_done;
	assign intf_motors.rdy = motors_rdy;

	assign servo_done = intf_servo.done;
	assign servo_rdy = intf_servo.rdy;

	assign steppers_done = intf_xy.done;
	assign steppers_rdy = intf_xy.rdy;

endmodule : MotorsCtrl_InnerConnect
