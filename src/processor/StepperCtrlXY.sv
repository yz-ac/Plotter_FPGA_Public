`include "../common/common.svh"

/**
* Module for controlling stepper motors in two axes.
* Pulses for the drivers are scaled to start and finish at the same time (contributing to a more "fluid" movement).
*
* :param COUNT_BITS_X: Number of bits for the number of steps in the X axis.
* :param COUNT_BITS_Y: Number of bits for the number of steps in the Y axis.
* :input clk: The clock of the system.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers the pulses for the stepper motor drivers.
* :input num_steps_x: Number of steps for the X stepper motor.
* :input num_steps_y: Number of steps for the Y stepper motor.
* :output out_x: The pulses for the X motor driver.
* :output dir_x: Direction of rotation of the X motor.
* :output out_y: The pulses for the Y motor driver.
* :output dir_y: Direction of rotation of the Y motor.
* :output done: Is the sequence of pulses finished in both axes
* 				(NOTE: this does NOT mean the mechanical parts have finished moving).
*/
module StepperCtrlXY #(
	COUNT_BITS_X = `BYTE_BITS,
	COUNT_BITS_Y = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic [COUNT_BITS_X-1:0] num_steps_x,
	input logic [COUNT_BITS_Y-1:0] num_steps_y,

	output logic out_x,
	output logic dir_x,
	output logic out_y,
	output logic dir_y,
	output logic done
);

	reg [COUNT_BITS_X-1:0] saved_num_steps_x;
	reg [COUNT_BITS_Y-1:0] saved_num_steps_y;

	reg [COUNT_BITS_Y-2:0] pulse_width_x;
	reg [COUNT_BITS_X-2:0] pulse_width_y;

	wire [COUNT_BITS_X-2:0] abs_num_steps_x;
	wire [COUNT_BITS_Y-2:0] abs_num_steps_y;
	wire done_x;
	wire done_y;

	StepperCtrl #(
		.COUNT_BITS(COUNT_BITS_X),
		.WIDTH_BITS(COUNT_BITS_Y - 1)
	) stepper_ctrl_x (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.num_steps(saved_num_steps_x),
		.pulse_width(pulse_width_x),
		.out(out_x),
		.dir(dir_x),
		.done(done_x)
	);

	StepperCtrl #(
		.COUNT_BITS(COUNT_BITS_Y),
		.WIDTH_BITS(COUNT_BITS_X - 1)
	) stepper_ctrl_y (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.num_steps(saved_num_steps_y),
		.pulse_width(pulse_width_y),
		.out(out_y),
		.dir(dir_y),
		.done(done_y)
	);

	assign done = done_x & done_y;

	Abs #(
		.BITS(COUNT_BITS_X)
	) num_steps_x_to_abs (
		.in(saved_num_steps_x),
		.out(abs_num_steps_x)
	);

	Abs #(
		.BITS(COUNT_BITS_Y)
	) num_steps_y_to_abs (
		.in(saved_num_steps_y),
		.out(abs_num_steps_y)
	);

	// If at least one of the num_steps is 0, no need to change pulse width.
	always_comb begin
		pulse_width_x = abs_num_steps_y;
		pulse_width_y = abs_num_steps_x;

		if ((~|abs_num_steps_x) | (~|abs_num_steps_y)) begin
			pulse_width_x = 1;
			pulse_width_y = 1;
		end
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			saved_num_steps_x <= num_steps_x;
			saved_num_steps_y <= num_steps_y;
		end
		else if (clk_en) begin
			saved_num_steps_x <= saved_num_steps_x;
			saved_num_steps_y <= saved_num_steps_y;
			// In standby
			if (done_x & done_y) begin
				saved_num_steps_x <= num_steps_x;
				saved_num_steps_y <= num_steps_y;
			end
		end
		else begin
			saved_num_steps_x <= saved_num_steps_x;
			saved_num_steps_y <= saved_num_steps_y;
		end
	end // always_ff

endmodule : StepperCtrlXY
