`include "../common/common.svh"

/**
* Module for controlling stepper motors.
* Outputs the needed number of pulses in order to rotate the motor 'num_steps'
* steps after a trigger.
*
* :param COUNT_BITS: Number of bits for the number of steps.
* :param WIDTH_BITS: Number of bits for the pulse width.
* :input clk: The clock of the system.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers the pulses for the stepper motor driver.
* :input num_steps: Number of steps for the stepper motor.
* :input pulse_width: Pulse width (in clk_en's).
* :output out: The pulses for the motor driver.
* :output dir: Direction of rotation.
* :output done: Is the sequence of pulses finished
* 				(NOTE: this does NOT mean the mechanical parts have finished moving).
*/
module StepperCtrl #(
	COUNT_BITS = `BYTE_BITS,
	WIDTH_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic [COUNT_BITS-1:0] num_steps,
	input logic [WIDTH_BITS-1:0] pulse_width,

	output logic out,
	output logic dir,
	output logic done
);

	wire working;

	reg counter_stop;
	reg [COUNT_BITS-1:0] saved_num_steps;
	reg [WIDTH_BITS-1:0] saved_pulse_width;
	reg [COUNT_BITS-2:0] abs_num_steps;
	reg [COUNT_BITS-1:0] pulse_num_counter;
	reg [WIDTH_BITS-1:0] pulse_width_counter;

	StepperCtrl_FSM fsm(
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.counter_stop(counter_stop),
		.working(working)
	);

	assign done = ~working;
	assign dir = saved_num_steps[COUNT_BITS-1];
	// Stepper needs pulses (clk_ens = num_steps x2)
	assign out = ~(pulse_num_counter[0]);

	always_comb begin
		abs_num_steps = saved_num_steps[COUNT_BITS-2:0];
		// Negative - two's complements
		if (saved_num_steps[COUNT_BITS-1]) begin
			abs_num_steps = (~(saved_num_steps[COUNT_BITS-2:0])) + 1;
		end
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			saved_num_steps <= num_steps;
			saved_pulse_width <= pulse_width;
			pulse_num_counter <= 1;
			pulse_width_counter <= 1;
			counter_stop <= 0;
		end
		else if (clk_en) begin
			counter_stop <= 0;
			saved_num_steps <= num_steps;
			saved_pulse_width <= pulse_width;
			pulse_num_counter <= 1;
			pulse_width_counter <= 1;
			if (working) begin
				pulse_width_counter <= pulse_width_counter + 1;
				if (pulse_width_counter == saved_pulse_width) begin
					pulse_num_counter <= pulse_num_counter + 1;
					pulse_width_counter <= 1;
				end
				saved_num_steps <= saved_num_steps;
				saved_pulse_width <= saved_pulse_width;
				if (pulse_num_counter[COUNT_BITS-1:1] == abs_num_steps) begin
					counter_stop <= 1;
					pulse_num_counter <= 1;
				end
			end
		end
		else begin
			saved_num_steps <= saved_num_steps;
			saved_pulse_width <= saved_pulse_width;
			pulse_num_counter <= pulse_num_counter;
			pulse_width_counter <= pulse_width_counter;
			counter_stop <= counter_stop;
		end
	end // always_ff

endmodule : StepperCtrl
