`include "common/common.svh"

/**
* Interface for controlling stepper motors.
*
* :param PULSE_NUM_BITS: Field width of number of pulses.
* :param PULSE_WIDTH_BITS: Field width for pulses widths to motors.
* :port pulse_num: Number of pulses.
* :port pulse_width: Width of pulses (in clk_en's).
* :port trigger: Triggers pulses to motors.
* :port done: Done sending pulses to motors.
* :port rdy: Ready to accept new triggers.
*/
interface StepperCtrl_IF #(
	parameter PULSE_NUM_BITS = `BYTE_BITS,
	parameter PULSE_WIDTH_BITS = `BYTE_BITS
) ();

	logic [PULSE_NUM_BITS-1:0] pulse_num;
	logic [PULSE_WIDTH_BITS-1:0] pulse_width;
	logic trigger;
	logic done;
	logic rdy;

	modport master (
		output trigger,
		output pulse_num,
		output pulse_width,
		input done,
		input rdy
	);

	modport slave (
		input trigger,
		input pulse_num,
		input pulse_width,
		output done,
		output rdy
	);

endinterface : StepperCtrl_IF
