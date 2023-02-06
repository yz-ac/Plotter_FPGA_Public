import Char_PKG::Char_t;
import Char_PKG::CHAR_NEWLINE;

/**
* FSM for ParserTop module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input rd_done: Done reading.
* :input rd_rdy: Reader ready to accept triggers.
* :input is_empty: Nothing left to read.
* :input wr_done: Writer done writing.
* :input wr_rdy: Writer ready to accept triggers.
* :input is_full: No place to write.
* :input cmd_parser_done: Command subparser done parsing.
* :input cmd_parser_rdy: Command subparser ready to accept triggers.
* :input cmd_parser_success: Command parser succeeded parsing.
* :input cmd_parser_newline: Command parser encountered newline.
* :input arg_parser_done: Argument subparser done parsing.
* :input arg_parser_rdy: Argument subparser ready to accept triggers.
* :input arg_parser_success: Argument parser succeeded parsing.
* :input arg_parser_newline: Argument parser encountered newline.
* :input char_type: Type of next character to parse.
* :output store: Store last read character for parsing.
* :output rd_trigger: Read a new char.
* :output wr_trigger: Write parsed opcode.
* :output cmd_parser_trigger: Trigger command subparser.
* :output arg_parser_trigger: Trigger argument subparser.
* :output connect_cmd: Connect the command subparser to the reader.
* :output connect_args: Connect the argument subparsers to the reader.
*/
module ParserTop_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic rd_done,
	input logic rd_rdy,
	input logic is_empty,
	input logic wr_done,
	input logic wr_rdy,
	input logic is_full,
	input logic cmd_parser_done,
	input logic cmd_parser_rdy,
	input logic cmd_parser_success,
	input logic cmd_parser_newline,
	input logic arg_parser_done,
	input logic arg_parser_rdy,
	input logic arg_parser_success,
	input logic arg_parser_newline,
	input Char_t char_type,

	output logic store,
	output logic rd_trigger,
	output logic wr_trigger,
	output logic cmd_parser_trigger,
	output logic arg_parser_trigger,
	output logic connect_cmd,
	output logic connect_args
);

	typedef enum {
		IDLE,
		CMD_WAIT_RDY,
		CMD_TRIGGER,
		CMD_WAIT_DONE,
		CMD_CHECK,
		ARGS_WAIT_RDY,
		ARGS_TRIGGER,
		ARGS_WAIT_DONE,
		ARGS_CHECK,
		WR_WAIT_RDY,
		WR_TRIGGER,
		WR_WAIT_DONE,
		CHECK_NEWLINE_AFTER_PARSE,
		RD_NEWLINE_WAIT_RDY,
		RD_NEWLINE_TRIGGER,
		RD_NEWLINE_WAIT_DONE,
		RD_NEWLINE_CHECK
	} ParserTop_state;

	ParserTop_state _cur_state;
	ParserTop_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = CMD_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;
		end
		CMD_WAIT_RDY: begin
			_nxt_state = CMD_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 1;
			connect_args = 0;

			if (cmd_parser_rdy) begin
				_nxt_state = CMD_TRIGGER;
			end
		end
		CMD_TRIGGER: begin
			_nxt_state = CMD_TRIGGER;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 1;
			arg_parser_trigger = 0;
			connect_cmd = 1;
			connect_args = 0;

			if (!cmd_parser_rdy) begin
				_nxt_state = CMD_WAIT_DONE;
			end
		end
		CMD_WAIT_DONE: begin
			_nxt_state = CMD_WAIT_DONE;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 1;
			connect_args = 0;

			if (cmd_parser_done) begin
				_nxt_state = CMD_CHECK;
			end
		end
		CMD_CHECK: begin
			_nxt_state = RD_NEWLINE_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 1;
			connect_args = 0;

			if (cmd_parser_success) begin
				_nxt_state = ARGS_WAIT_RDY;
			end
			else if (cmd_parser_newline) begin
				_nxt_state = IDLE;
			end
		end
		ARGS_WAIT_RDY: begin
			_nxt_state = ARGS_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 1;

			if (arg_parser_rdy) begin
				_nxt_state = ARGS_TRIGGER;
			end
		end
		ARGS_TRIGGER: begin
			_nxt_state = ARGS_TRIGGER;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 1;
			connect_cmd = 0;
			connect_args = 1;

			if (!arg_parser_rdy) begin
				_nxt_state = ARGS_WAIT_DONE;
			end
		end
		ARGS_WAIT_DONE: begin
			_nxt_state = ARGS_WAIT_DONE;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 1;

			if (arg_parser_done) begin
				_nxt_state = ARGS_CHECK;
			end
		end
		ARGS_CHECK: begin
			_nxt_state = CHECK_NEWLINE_AFTER_PARSE;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 1;

			if (arg_parser_success) begin
				_nxt_state = WR_WAIT_RDY;
			end
		end
		WR_WAIT_RDY: begin
			_nxt_state = WR_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (wr_rdy & !is_full) begin
				_nxt_state = WR_TRIGGER;
			end
		end
		WR_TRIGGER: begin
			_nxt_state = WR_TRIGGER;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 1;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (!wr_rdy) begin
				_nxt_state = WR_WAIT_DONE;
			end
		end
		WR_WAIT_DONE: begin
			_nxt_state = WR_WAIT_DONE;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (wr_done) begin
				_nxt_state = CHECK_NEWLINE_AFTER_PARSE;
			end
		end
		CHECK_NEWLINE_AFTER_PARSE: begin
			_nxt_state = RD_NEWLINE_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (arg_parser_newline) begin
				_nxt_state = IDLE;
			end
		end
		RD_NEWLINE_WAIT_RDY: begin
			_nxt_state = RD_NEWLINE_WAIT_RDY;
			store = 1;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (rd_rdy & !is_empty) begin
				_nxt_state = RD_NEWLINE_TRIGGER;
			end
		end
		RD_NEWLINE_TRIGGER: begin
			_nxt_state = RD_NEWLINE_TRIGGER;
			store = 0;
			rd_trigger = 1;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (!rd_rdy) begin
				_nxt_state = RD_NEWLINE_WAIT_DONE;
			end
		end
		RD_NEWLINE_WAIT_DONE: begin
			_nxt_state = RD_NEWLINE_WAIT_DONE;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (rd_done) begin
				_nxt_state = RD_NEWLINE_CHECK;
			end
		end
		RD_NEWLINE_CHECK: begin
			_nxt_state = RD_NEWLINE_WAIT_RDY;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;

			if (char_type == CHAR_NEWLINE) begin
				_nxt_state = IDLE;
			end
		end
		default: begin
			_nxt_state = IDLE;
			store = 0;
			rd_trigger = 0;
			wr_trigger = 0;
			cmd_parser_trigger = 0;
			arg_parser_trigger = 0;
			connect_cmd = 0;
			connect_args = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= IDLE;
		end
		else if (clk_en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : ParserTop_FSM
