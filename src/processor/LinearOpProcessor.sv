`include "../../src/processor/processor.svh"

import Opcode_p::Opcode_st;
import Opcode_p::Opcode_t;
import Servo_p::ServoPosition_t;

/**
* Unit for processing linear opcode and control of servo and steppers accordingly.
* 
* :param OP_BITS: Number of bits in the OP field.
* :param ARG_BITS: Number of bits the argument fields.
* :param FLAG_BITS: Number of bits in the flags field.
* :param STEPPER_X_BITS: Number of bits in the number of steps in the x direction.
* :param STEPPER_Y_BITS: Number of bits in the number of steps in the y direction.
* :input clk: The clock of the system.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger_in: Triggers this module (comes from OP field processing unit).
* :input done_in: Motor control units are done.
* :input opcode: The opcode struct.
* :output servo_pos: Servo position.
* :output num_steps_x: Number of steps to move in the x direction.
* :output num_steps_y: Number of steps to move in the y direction.
* :output trigger_out: Triggers the motor control units.
* :output done_out: Signals the parent unit that the operation of this module is finished.
*/
module LinearOpProcessor #(
	OP_BITS = `OP_BITS,
	ARG_BITS = `ARG_BITS,
	FLAG_BITS = `FLAG_BITS,
	STEPPER_X_BITS = `STEPPER_X_BITS,
	STEPPER_Y_BITS = `STEPPER_Y_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,

	input logic trigger_in,
	input logic done_in,
	input Opcode_p::Opcode_st opcode,

	output Servo_p::ServoPosition_t servo_pos,
	output logic [STEPPER_X_BITS-1:0] num_steps_x,
	output logic [STEPPER_Y_BITS-1:0] num_steps_y,
	output logic trigger_out,
	output logic done_out
);

	LinearOpProcessor_FSM fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger_in(trigger_in),
		.done_in(done_in),
		.trigger_out(trigger_out),
		.done_out(done_out)
	);

	assign num_steps_x = opcode.arg1;
	assign num_steps_y = opcode.arg2;
	assign servo_pos = (opcode.op == Opcode_p::OP_G01) ? (Servo_p::SERVO_POS_DOWN) : (Servo_p::SERVO_POS_UP);

endmodule : LinearOpProcessor
