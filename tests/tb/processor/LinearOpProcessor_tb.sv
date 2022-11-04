`include "../../../src/processor/processor.svh"

import Opcode_p::Opcode_st;
import Servo_p::ServoPosition_t;

module LinearOpProcessor_tb;

	localparam OP_BITS = `OP_BITS;
	localparam ARG_BITS = `ARG_BITS;
	localparam FLAG_BITS = `FLAG_BITS;
	localparam STEPPER_X_BITS = `STEPPER_X_BITS;
	localparam STEPPER_Y_BITS = `STEPPER_Y_BITS;
	localparam CLK_EN_BITS = `BYTE_BITS;

	reg clk;
	reg reset;

	reg trigger_in;
	reg done_in;
	Opcode_p::Opcode_st opcode;

	wire clk_en;
	Servo_p::ServoPosition_t servo_pos;
	wire [STEPPER_X_BITS-1:0] num_steps_x;
	wire [STEPPER_Y_BITS-1:0] num_steps_y;
	wire trigger_out;
	wire done_out;

	ClockEnabler #(
		.PERIOD_BITS(CLK_EN_BITS)
	) clk_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(2),
		.out(clk_en)
	);

	LinearOpProcessor #(
		.OP_BITS(OP_BITS),
		.ARG_BITS(ARG_BITS),
		.FLAG_BITS(FLAG_BITS),
		.STEPPER_X_BITS(STEPPER_X_BITS),
		.STEPPER_Y_BITS(STEPPER_Y_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger_in(trigger_in),
		.done_in(done_in),
		.opcode(opcode),
		.servo_pos(servo_pos),
		.num_steps_x(num_steps_x),
		.num_steps_y(num_steps_y),
		.trigger_out(trigger_out),
		.done_out(done_out)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 58 clks
	initial begin
		reset = 1;
		trigger_in = 0;
		done_in = 1;
		opcode = {Opcode_p::OP_G00, 3, -4, 0, 0, 0};
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		trigger_in = 1;
		done_in = 0;
		#(`CLOCK_PERIOD * 2);

		trigger_in = 0;
		#(`CLOCK_PERIOD * 10);

		done_in = 1;
		#(`CLOCK_PERIOD * 10);

		done_in = 0;
		trigger_in = 1;
		opcode.op = Opcode_p::OP_G01;
		#(`CLOCK_PERIOD * 2);

		trigger_in = 0;
		#(`CLOCK_PERIOD * 10);

		done_in = 1;
		#(`CLOCK_PERIOD * 10);

		trigger_in = 1; // done_in stays up deliberatly
		#(`CLOCK_PERIOD * 2);

		trigger_in = 0;
		#(`CLOCK_PERIOD * 10);

	end

endmodule : LinearOpProcessor_tb
