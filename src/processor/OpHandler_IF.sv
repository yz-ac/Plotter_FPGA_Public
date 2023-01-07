/**
* Interface for opcode handlers.
*
* :port op: Opcode to be processed.
* :port trigger: Triggers handler.
* :port done: Logic is done.
* :port rdy: Ready to accept triggers.
*/
interface OpHandler_IF ();

	logic trigger;
	logic done;
	logic rdy;

	modport master (
		output trigger,
		input done,
		input rdy
	);

	modport slave (
		input trigger,
		output done,
		output rdy
	);

endinterface : OpHandler_IF
