import Op_PKG::Op_st;

/**
* Interface for opcode handlers.
*
* :port op: Opcode to be processed.
* :port trigger: Triggers handler.
* :port done: Logic is done.
* :port rdy: Ready to accept triggers.
*/
interface OpHandler_IF ();

	Op_st op;
	logic trigger;
	logic done;
	logic rdy;

	modport master (
		output op,
		output trigger,
		input done,
		input rdy
	);

	modport slave (
		input op,
		input trigger,
		output done,
		output rdy
	);

endinterface : OpHandler_IF
