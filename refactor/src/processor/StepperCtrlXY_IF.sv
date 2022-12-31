`include "common/common.svh"

/**
* Interface for StepperCtrlXY.
*
* :param PULSE_NUM_X_BITS: Field width of number of pulses for X direction.
* :param PULSE_NUM_Y_BITS: Field width of number of pulses for Y direction.
* :param PULSE_WIDTH_BITS: Field width of pulse width.
* :port pulse_num_x: Number of pulses in X direction.
* :port pulse_num_y: Number of pulses in Y direction.
* :port pulse_width: Minimum pulse width.
* :port trigger: Triggers the module.
* :port done: Logic finished.
* :port rdy: Logic accepts new triggers.
*/
interface StepperCtrlXY_IF #(
	parameter PULSE_NUM_X_BITS = `BYTE_BITS,
	parameter PULSE_NUM_Y_BITS = `BYTE_BITS,
	parameter PULSE_WIDTH_BITS = `BYTE_BITS
) ();

	logic [PULSE_NUM_X_BITS-1:0] pulse_num_x;
	logic [PULSE_NUM_Y_BITS-1:0] pulse_num_y;
	logic [PULSE_WIDTH_BITS-1:0] pulse_width;
	logic trigger;
	logic done;
	logic rdy;

	modport master (
		output pulse_num_x,
		output pulse_num_y,
		output pulse_width,
		output trigger,
		input done,
		input rdy
	);

	modport slave (
		input pulse_num_x,
		input pulse_num_y,
		input pulse_width,
		input trigger,
		output done,
		output rdy
	);

endinterface : StepperCtrlXY_IF
