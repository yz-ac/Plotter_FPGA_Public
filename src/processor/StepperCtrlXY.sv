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

	wire trigger_x;
	wire trigger_y;

	wire working_x;
	wire working_y;

	wire clk_en_x;
	wire clk_en_y;

	wire is_standby;

	reg [COUNT_BITS_X-1:0] saved_num_steps_x;
	reg [COUNT_BITS_Y-1:0] saved_num_steps_y;

	reg [COUNT_BITS_X-2:0] abs_num_steps_x;
	reg [COUNT_BITS_Y-2:0] abs_num_steps_y;

	reg [COUNT_BITS_Y-2:0] scale_x;
	reg [COUNT_BITS_X-2:0] scale_y;

	FreqDivider #(
		.DIV_BITS(COUNT_BITS_Y-1)
	) freq_div_x (
		.clk(clk),
		.reset(reset),
		.signal_in(clk_en),
		.div_val(scale_x),
		.signal_out(clk_en_x)
	);

	FreqDivider #(
		.DIV_BITS(COUNT_BITS_X-1)
	) freq_div_y (
		.clk(clk),
		.reset(reset),
		.signal_in(clk_en),
		.div_val(scale_y),
		.signal_out(clk_en_y)
	);

	StepperCtrl #(
		.COUNT_BITS(COUNT_BITS_X),
		.WIDTH_BITS(COUNT_BITS_Y - 1)
	) stepper_ctrl_x (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en_x),
		.trigger(trigger_x),
		.num_steps(saved_num_steps_x),
		.pulse_width(1),
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
		.clk_en(clk_en_y),
		.trigger(trigger_y),
		.num_steps(saved_num_steps_y),
		.pulse_width(1),
		.out(out_y),
		.dir(dir_y),
		.done(done_y)
	);

	StepperCtrlXY_FSM fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.working_x(working_x),
		.working_y(working_y),
		.trigger_x(trigger_x),
		.trigger_y(trigger_y),
		.is_standby(is_standby)
	);

	assign done = done_x & done_y;

	assign working_x = ~done_x;
	assign working_y = ~done_y;

	always_comb begin
		abs_num_steps_x = saved_num_steps_x[COUNT_BITS_X-2:0];
		abs_num_steps_y = saved_num_steps_y[COUNT_BITS_Y-2:0];

		// Negative - two's complements
		if (saved_num_steps_x[COUNT_BITS_X-1]) begin
			abs_num_steps_x = (~saved_num_steps_x[COUNT_BITS_X-2:0]) + 1;
		end
		if (saved_num_steps_y[COUNT_BITS_Y-1]) begin
			abs_num_steps_y = (~saved_num_steps_y[COUNT_BITS_Y-2:0]) + 1;
		end
	end // always_comb

	// If at least one of the num_steps is 0, no need to scale clk_en
	always_comb begin
		scale_x = abs_num_steps_y;
		scale_y = abs_num_steps_x;

		if ((~|abs_num_steps_x) | (~|abs_num_steps_y)) begin
			scale_x = 1;
			scale_y = 1;
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
			if (is_standby) begin
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
