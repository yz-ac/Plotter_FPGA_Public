/**
* Interface for subparsers.
*
* :port trigger: Triggers the subparser.
* :port done: Subparser is done.
* :port rdy: Subparser is ready to accept triggers.
* :port rd_trigger: Subparser requests read.
* :port rd_done: Read request done.
* :port rd_rdy: Reader ready to accept triggers.
* :port is_empty: No more data can be read.
* :port success: Is parsing successful.
*/
interface Subparser_IF ();

	logic trigger;
	logic done;
	logic rdy;
	logic rd_trigger;
	logic rd_done;
	logic rd_rdy;
	logic is_empty;
	logic success;

	modport master (
		output trigger,
		input done,
		input rdy,
		input rd_trigger,
		output rd_done,
		output rd_rdy,
		output is_empty,
		input success
	);

	modport slave (
		input trigger,
		output done,
		output rdy,
		output rd_trigger,
		input rd_done,
		input rd_rdy,
		input is_empty,
		output success
	);

endinterface : Subparser_IF
