/**
* Internal connections for parsers controlling other subparsers.
*
* :input arg_parser_trigger: Trigger to argument subparser.
* :input arg_parser_rd_done: Reader done signal to argument subparser.
* :input arg_parser_rd_rdy: Reader ready signal to argument subparser.
* :input arg_parser_is_empty: Nothing to read signal to argument subparser.
* :iface arg_intf: Interface to argument subparser.
* :output arg_parser_done: Argument subparser is done parsing.
* :output arg_parser_rdy: Argument subparser ready to accept triggers.
* :output arg_parser_rd_trigger: Argument subparser requests read.
* :output arg_parser_success: Argument subparser succeeded parsing.
* :output arg_parser_newline: Argument subparser encountered newline while parsing.
*/
module Subparser_InnerConnect (
	input logic arg_parser_trigger,
	input logic arg_parser_rd_done,
	input logic arg_parser_rd_rdy,
	input logic arg_parser_is_empty,

	Subparser_IF arg_intf,

	output logic arg_parser_done,
	output logic arg_parser_rdy,
	output logic arg_parser_rd_trigger,
	output logic arg_parser_success,
	output logic arg_parser_newline
);

	assign arg_intf.trigger = arg_parser_trigger;
	assign arg_parser_done = arg_intf.done;
	assign arg_parser_rdy = arg_intf.rdy;
	assign arg_parser_rd_trigger = arg_intf.rd_trigger;
	assign arg_intf.rd_done = arg_parser_rd_done;
	assign arg_intf.rd_rdy = arg_parser_rd_rdy;
	assign arg_intf.is_empty = arg_parser_is_empty;
	assign arg_parser_success = arg_intf.success;
	assign arg_parser_newline = arg_intf.newline;

endmodule : Subparser_InnerConnect
