/**
* Module to control stepper motors.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Logic enabling clock.
* :iface intf: Stepper control interface.
* :output out: Output signal to stepper driver.
* :output dir: Direction signal to stepper driver.
*/
module StepperCtrl (
	input logic clk,
	input logic reset,
	input logic clk_en,
	StepperCtrl_IF intf,
	output logic out,
	output logic dir
);

	wire [intf.PULSE_NUM_BITS-2:0] _abs_pulse_num;

	Abs #(
		.NUM_BITS(intf.PULSE_NUM_BITS)
	) _abs (
		.num(intf.pulse_num),
		.out(_abs_pulse_num)
	);

	PulseGen #(
		.PULSE_NUM_BITS(intf.PULSE_NUM_BITS-1),
		.PULSE_WIDTH_BITS(intf.PULSE_WIDTH_BITS)
	) _pulse_gen (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.pulse_num(_abs_pulse_num),
		.pulse_width(intf.pulse_width),
		.trigger(intf.trigger),
		.out(out),
		.done(intf.done),
		.rdy(intf.rdy)
	);

	assign dir = intf.pulse_num[intf.PULSE_NUM_BITS-1];

endmodule : StepperCtrl