`include "common/common.svh"

/**
* Module to control stepper motors.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input en: Enables the module.
* :iface intf: Stepper control interface.
*/
module StepperCtrl (
	input logic clk,
	input logic reset,
	input logic en,
	StepperCtrl_IF intf
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
		.en(en),
		.pulse_num(_abs_pulse_num),
		.pulse_width(intf.pulse_width),
		.trigger(intf.trigger),
		.out(intf.out),
		.done(intf.done)
	);

	assign intf.dir = intf.pulse_num[intf.PULSE_NUM_BITS-1];

endmodule : StepperCtrl
