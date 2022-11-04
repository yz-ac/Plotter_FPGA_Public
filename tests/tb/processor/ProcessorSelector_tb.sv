`include "../../../src/processor/processor.svh"

import Opcode_p::Opcode_st;
import Opcode_p::Opcode_t;
import Servo_p::ServoPosition_t;

module ProcessorSelector_tb;

	localparam OP_BITS = `OP_BITS;
	localparam STEPPER_X_BITS = `STEPPER_X_BITS;
	localparam STEPPER_Y_BITS = `STEPPER_Y_BITS;

	Opcode_p::Opcode_st opcode;
	
	wire lin_trigger_out;
	wire lin_stepper_done_out;
	wire circ_trigger_out;
	wire circ_stepper_done_out;
	wire [STEPPER_X_BITS-1:0] num_steps_x_out;
	wire [STEPPER_Y_BITS-1:0] num_steps_y_out;
	Servo_p::ServoPosition_t servo_pos_out;
	wire done_out;

	ProcessorSelector #(
		.OP_BITS(OP_BITS),
		.STEPPER_X_BITS(STEPPER_X_BITS),
		.STEPPER_Y_BITS(STEPPER_Y_BITS)
	) UUT (
		.op(opcode.op),
		.trigger_in(1),
		.stepper_done_in(1),
		.lin_num_steps_x_in(4),
		.lin_num_steps_y_in(-3),
		.lin_servo_pos_in(Servo_p::SERVO_POS_UP),
		.lin_done_in(1),
		.circ_num_steps_x_in(5),
		.circ_num_steps_y_in(6),
		.circ_servo_pos_in(Servo_p::SERVO_POS_DOWN),
		.circ_done_in(0),
		.lin_trigger_out(lin_trigger_out),
		.lin_stepper_done_out(lin_stepper_done_out),
		.circ_trigger_out(circ_trigger_out),
		.circ_stepper_done_out(circ_stepper_done_out),
		.num_steps_x_out(num_steps_x_out),
		.num_steps_y_out(num_steps_y_out),
		.servo_pos_out(servo_pos_out),
		.done_out(done_out)
	);

	// 40 clks
	initial begin
		opcode = {Opcode_p::OP_G00, 0, 0, 0, 0, 0};
		#(`CLOCK_PERIOD * 10);

		opcode.op = Opcode_p::OP_G02;
		#(`CLOCK_PERIOD * 10);

		opcode.op = Opcode_p::OP_G01;
		#(`CLOCK_PERIOD * 10);

		opcode.op = Opcode_p::OP_G03;
		#(`CLOCK_PERIOD * 10);
	end

endmodule : ProcessorSelector_tb
