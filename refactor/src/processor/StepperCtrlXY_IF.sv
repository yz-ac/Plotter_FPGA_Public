`include "common/common.svh"

interface StepperCtrlXY_IF #(
	PULSE_NUM_X_BITS = `BYTE_BITS,
	PULSE_NUM_Y_BITS = `BYTE_BITS,
	PULSE_WIDTH_BITS = `BYTE_BITS
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
