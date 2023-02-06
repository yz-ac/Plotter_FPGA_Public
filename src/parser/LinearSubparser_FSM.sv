import Char_PKG::Char_t;
import Char_PKG::CHAR_X;
import Char_PKG::CHAR_Y;
import Char_PKG::CHAR_UNKNOWN;

/**
* FSM for LinearSubparser module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers parsing logic.
* :input arg_parser_done: Argument subparser done parsing.
* :input arg_parser_rdy: Argument subparser ready to accept triggers.
* :input arg_parser_success: Argument subparser parsed successfully.
* :input arg_parser_newline: Argument subparser encountered newline while parsing.
* :input arg_too_big: Argument number is to big to fit in field.
* :output zero: Zero all buffers and flags.
* :output set_cmd: Set 'cmd' field of opcode.
* :output arg_title: Argument type to look for.
* :output arg_parser_trigger: Trigger argument subparser.
* :output set_x: Set 'x' field of opcode.
* :output set_y: Set 'y' field of opcode.
* :output update_pos: Update precise position.
* :output set_success: Set success flag.
* :output set_newline: Encountered newline while parsing.
* :output done: Done parsing.
* :output rdy: Ready to accept triggers.
*/
module LinearSubparser_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input logic arg_parser_done,
	input logic arg_parser_rdy,
	input logic arg_parser_success,
	input logic arg_parser_newline,
	input logic arg_too_big,

	output logic zero,
	output logic set_cmd,
	output Char_t arg_title,
	output logic arg_parser_trigger,
	output logic set_x,
	output logic set_y,
	output logic update_pos,
	output logic set_success,
	output logic set_newline,
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		ZERO,
		SET_CMD,
		PARSE_X_WAIT_RDY,
		PARSE_X_TRIGGER,
		PARSE_X_WAIT_DONE,
		PARSE_X_CHECK,
		SET_X,
		PARSE_Y_WAIT_RDY,
		PARSE_Y_TRIGGER,
		PARSE_Y_WAIT_DONE,
		PARSE_Y_CHECK,
		SET_Y,
		UPDATE_POS,
		SET_NEWLINE_AND_CONTINUE,
		SET_NEWLINE_AND_FAIL,
		SET_SUCCESS,
		DONE
	} LinearSubparser_state;

	LinearSubparser_state _cur_state;
	LinearSubparser_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 1;
			rdy = 1;

			if (trigger) begin
				_nxt_state = ZERO;
				done = 0;
			end
		end
		ZERO: begin
			_nxt_state = SET_CMD;
			zero = 1;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		SET_CMD: begin
			_nxt_state = PARSE_X_WAIT_RDY;
			zero = 0;
			set_cmd = 1;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		PARSE_X_WAIT_RDY: begin
			_nxt_state = PARSE_X_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_X;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_rdy) begin
				_nxt_state = PARSE_X_TRIGGER;
			end
		end
		PARSE_X_TRIGGER: begin
			_nxt_state = PARSE_X_TRIGGER;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_X;
			arg_parser_trigger = 1;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (!arg_parser_rdy) begin
				_nxt_state = PARSE_X_WAIT_DONE;
			end
		end
		PARSE_X_WAIT_DONE: begin
			_nxt_state = PARSE_X_WAIT_DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_X;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_done) begin
				_nxt_state = PARSE_X_CHECK;
			end
		end
		PARSE_X_CHECK: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_X;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_success & !arg_parser_newline & !arg_too_big) begin
				_nxt_state = SET_X;
			end
			else if (arg_parser_newline) begin
				_nxt_state = SET_NEWLINE_AND_FAIL;
			end
		end
		SET_X: begin
			_nxt_state = PARSE_Y_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_X;
			arg_parser_trigger = 0;
			set_x = 1;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		PARSE_Y_WAIT_RDY: begin
			_nxt_state = PARSE_Y_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_rdy) begin
				_nxt_state = PARSE_Y_TRIGGER;
			end
		end
		PARSE_Y_TRIGGER: begin
			_nxt_state = PARSE_Y_TRIGGER;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 1;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (!arg_parser_rdy) begin
				_nxt_state = PARSE_Y_WAIT_DONE;
			end
		end
		PARSE_Y_WAIT_DONE: begin
			_nxt_state = PARSE_Y_WAIT_DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_done) begin
				_nxt_state = PARSE_Y_CHECK;
			end
		end
		PARSE_Y_CHECK: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_success & arg_parser_newline & !arg_too_big) begin
				_nxt_state = SET_NEWLINE_AND_CONTINUE;
			end
			else if (arg_parser_success & !arg_too_big) begin
				_nxt_state = SET_Y;
			end
			else if (arg_parser_newline) begin
				_nxt_state = SET_NEWLINE_AND_FAIL;
			end
		end
		SET_Y: begin
			_nxt_state = UPDATE_POS;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 1;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		UPDATE_POS: begin
			_nxt_state = SET_SUCCESS;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 1;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		SET_NEWLINE_AND_CONTINUE: begin
			_nxt_state = SET_Y;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 1;
			done = 0;
			rdy = 0;
		end
		SET_NEWLINE_AND_FAIL: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 1;
			done = 0;
			rdy = 0;
		end
		SET_SUCCESS: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 1;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 1;
			rdy = 1;
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

endmodule : LinearSubparser_FSM
