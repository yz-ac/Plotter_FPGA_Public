/**
* Inner connection of ParserTop module - chooses which subparser is connected
* to the reader according to FSM flags.
*
* :input connect_cmd: Connect the command subparser to the reader.
* :input connect_args: Connect the argument subparser to the reader.
* :input rd_done: Reader is done.
* :input rd_rdy: Reader ready to accept triggers.
* :input is_empty: Nothing left to read.
* :input cmd_rd_trigger: Read trigger from command subparser.
* :input args_rd_trigger: Read trigger from argument subparsers.
* :input main_rd_trigger: Read trigger from the main parser.
* :output rd_trigger: Read trigger to the reader.
* :output cmd_rd_done: Reader is done to the command subparser.
* :output cmd_rd_rdy: Reader is done to the command subparser.
* :output cmd_is_empty: Nothing left to read signal to the command subparser.
* :output args_rd_done: Reader is done to the argument subparser.
* :output args_rd_rdy: Reader is done to the argument subparser.
* :output args_is_empty: Nothing left to read signal to the argument subparser.
* :output main_rd_done: Reader is done to the main parser.
* :output main_rd_rdy: Reader is done to the main parser.
* :output main_is_empty: Nothing left to read signal to the main parser.
*/
module ParserTop_InnerConnect (
	input logic connect_cmd,
	input logic connect_args,
	input logic rd_done,
	input logic rd_rdy,
	input logic is_empty,
	input logic cmd_rd_trigger,
	input logic args_rd_trigger,
	input logic main_rd_trigger,

	output logic rd_trigger,
	output logic cmd_rd_done,
	output logic cmd_rd_rdy,
	output logic cmd_is_empty,
	output logic args_rd_done,
	output logic args_rd_rdy,
	output logic args_is_empty,
	output logic main_rd_done,
	output logic main_rd_rdy,
	output logic main_is_empty
);

	always_comb begin
		rd_trigger = 0;
		cmd_rd_done = 0;
		cmd_rd_rdy = 0;
		cmd_is_empty = 0;
		args_rd_done = 0;
		args_rd_rdy = 0;
		args_is_empty = 0;
		main_rd_done = 0;
		main_rd_rdy = 0;
		main_is_empty = 0;

		if (connect_cmd) begin
			rd_trigger = cmd_rd_trigger;
			cmd_rd_done = rd_done;
			cmd_rd_rdy = rd_rdy;
			cmd_is_empty = is_empty;
		end
		else if (connect_args) begin
			rd_trigger = args_rd_trigger;
			args_rd_done = rd_done;
			args_rd_rdy = rd_rdy;
			args_is_empty = is_empty;
		end
		else begin
			rd_trigger = main_rd_trigger;
			main_rd_done = rd_done;
			main_rd_rdy = rd_rdy;
			main_is_empty = is_empty;
		end
	end // always_comb

endmodule : ParserTop_InnerConnect
