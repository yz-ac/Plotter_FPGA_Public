`include "../../src/processor/processor.svh"

import Servo_p::ServoPosition_t;
import Opcode_p::Opcode_t;

/**
* Chooses processor to handle opcode and correctly redirects its IO.
* This module is essentialy two MUXes: one between the opcode handler and the specific handler,
* and one between the specific handlers and the motor controls.
* 
* :param OP_BITS: Number of bits for the op field.
* :param STEPPER_X_BITS: Number of bits for the steppers x output.
* :param STEPPER_Y_BITS: Number of bits for the steppers y output.
* :input op: Op field to determine the processor to handle the opcode.
* :input trigger_in: Trigger from the Opcode handler.
* :input stepper_done_in: Done signal from the stepper controller.
* :input lin_num_steps_x_in: X steps number from the linear handler.
* :input lin_num_steps_y_in: Y steps number from the linear handler.
* :input lin_servo_pos_in: Servo position from the linear handler.
* :input circ_num_steps_x_in: X steps number from the circular handler.
* :input circ_num_steps_y_in: Y steps number from the circular handler.
* :input circ_servo_pos_in: Servo position from the circular handler.
* :output lin_trigger_out: Trigger to the linear handler.
* :output lin_stepper_done_out: Done signal from the stepper to the linear handler.
* :output circ_trigger_out: Trigger to the circular handler.
* :output circ_stepper_done_out: Done signal from the stepper to the circular handler.
* :output num_steps_x_out: Number of x steps to the stepper control.
* :output num_steps_y_out: Number of y steps to the stepper control.
* :output servo_pos_out: Position signal to the servo.
* :output done_out: Done signal to the opcode handler.
*/
module ProcessorSelector #(
	OP_BITS = `OP_BITS,
	STEPPER_X_BITS = `STEPPER_X_BITS,
	STEPPER_Y_BITS = `STEPPER_Y_BITS
)
(
	input logic [OP_BITS-1:0] op,
	input logic trigger_in,
	input logic stepper_done_in,

	input logic [STEPPER_X_BITS-1:0] lin_num_steps_x_in,
	input logic [STEPPER_Y_BITS-1:0] lin_num_steps_y_in,
	input Servo_p::ServoPosition_t lin_servo_pos_in,
	input logic lin_done_in,

	input logic [STEPPER_X_BITS-1:0] circ_num_steps_x_in,
	input logic [STEPPER_Y_BITS-1:0] circ_num_steps_y_in,
	input Servo_p::ServoPosition_t circ_servo_pos_in,
	input logic circ_done_in,

	output logic lin_trigger_out,
	output logic lin_stepper_done_out,

	output logic circ_trigger_out,
	output logic circ_stepper_done_out,

	output logic [STEPPER_X_BITS-1:0] num_steps_x_out,
	output logic [STEPPER_Y_BITS-1:0] num_steps_y_out,
	output Servo_p::ServoPosition_t servo_pos_out,
	output logic done_out
);

	always_comb begin
		lin_trigger_out = 0;
		lin_stepper_done_out = 0;
		circ_trigger_out = 0;
		circ_stepper_done_out = 0;
		num_steps_x_out = 0;
		num_steps_y_out = 0;
		servo_pos_out = Servo_p::SERVO_POS_UP;
		done_out = 0;
		case (op)
			Opcode_p::OP_G00: begin
				lin_trigger_out = trigger_in;
				lin_stepper_done_out = stepper_done_in;
				num_steps_x_out = lin_num_steps_x_in;
				num_steps_y_out = lin_num_steps_y_in;
				servo_pos_out = lin_servo_pos_in;
				done_out = lin_done_in;
			end

			Opcode_p::OP_G01: begin
				lin_trigger_out = trigger_in;
				lin_stepper_done_out = stepper_done_in;
				num_steps_x_out = lin_num_steps_x_in;
				num_steps_y_out = lin_num_steps_y_in;
				servo_pos_out = lin_servo_pos_in;
				done_out = lin_done_in;
			end

			Opcode_p::OP_G02: begin
				circ_trigger_out = trigger_in;
				circ_stepper_done_out = stepper_done_in;
				num_steps_x_out = circ_num_steps_x_in;
				num_steps_y_out = circ_num_steps_y_in;
				servo_pos_out = circ_servo_pos_in;
				done_out = circ_done_in;
			end

			Opcode_p::OP_G03: begin
				circ_trigger_out = trigger_in;
				circ_stepper_done_out = stepper_done_in;
				num_steps_x_out = circ_num_steps_x_in;
				num_steps_y_out = circ_num_steps_y_in;
				servo_pos_out = circ_servo_pos_in;
				done_out = circ_done_in;
			end
		endcase
	end // always_comb

endmodule : ProcessorSelector
