/**
* Connector between Subparser Interface and distinct wires.
*
* :input subparser_trigger: Trigger to subparser.
* :input subparser_rd_done: Reader done signal to subparser.
* :input subparser_rd_rdy: Reader ready signal to subparser.
* :input subparser_is_empty: Nothing to read signal to subparser.
* :iface sub_intf: Interface to subparser.
* :output subparser_done: Subparser is done parsing.
* :output subparser_rdy: Subparser ready to accept triggers.
* :output subparser_rd_trigger: Subparser requests read.
* :output subparser_success: Subparser succeeded parsing.
* :output subparser_newline: Subparser encountered newline while parsing.
*/
module SubparserConnector (
	input logic subparser_trigger,
	input logic subparser_rd_done,
	input logic subparser_rd_rdy,
	input logic subparser_is_empty,

	Subparser_IF sub_intf,

	output logic subparser_done,
	output logic subparser_rdy,
	output logic subparser_rd_trigger,
	output logic subparser_success,
	output logic subparser_newline
);

	assign sub_intf.trigger = subparser_trigger;
	assign subparser_done = sub_intf.done;
	assign subparser_rdy = sub_intf.rdy;
	assign subparser_rd_trigger = sub_intf.rd_trigger;
	assign sub_intf.rd_done = subparser_rd_done;
	assign sub_intf.rd_rdy = subparser_rd_rdy;
	assign sub_intf.is_empty = subparser_is_empty;
	assign subparser_success = sub_intf.success;
	assign subparser_newline = sub_intf.newline;

endmodule : SubparserConnector
