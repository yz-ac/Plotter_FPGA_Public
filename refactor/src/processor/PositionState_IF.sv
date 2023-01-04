`include "processor/processor.svh"

/**
* Interface for keeping current position state.
*
* :port cur_x: Current X position.
* :port cur_y: Current Y position.
* :port is_absolute: Is in absolute position mode.
*/
interface PositionState_IF #(
	parameter POS_X_BITS = `POS_X_BITS,
	parameter POS_Y_BITS = `POS_Y_BITS
) ();

	logic [POS_X_BITS-1:0] cur_x;
	logic [POS_Y_BITS-1:0] cur_y;
	logic is_absolute;

	modport master (
		output cur_x,
		output cur_y,
		output is_absolute
	);

	modport slave (
		input cur_x,
		input cur_y,
		input is_absolute
	);

endinterface : PositionState_IF
