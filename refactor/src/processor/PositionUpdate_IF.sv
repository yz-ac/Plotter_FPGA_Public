`include "processor/position.svh"

/**
* Interface for updating position.
*
* :port new_x: New absolute X position.
* :port new_y: New absolute Y position.
* :port update: Should position be updated.
*/
interface PositionUpdate_IF #(
	parameter POS_X_BITS = `POS_X_BITS,
	parameter POS_Y_BITS = `POS_Y_BITS
) ();

	logic [POS_X_BITS-1:0] new_x;
	logic [POS_Y_BITS-1:0] new_y;
	logic update;

	modport master (
		output new_x,
		output new_y,
		output update
	);

	modport slave (
		input new_x,
		input new_y,
		input update
	);

endinterface : PositionUpdate_IF
