import Char_PKG::Char_t;
import Char_PKG::CHAR_X;
import Char_PKG::CHAR_Y;
import Char_PKG::CHAR_I;
import Char_PKG::CHAR_J;
import Char_PKG::CHAR_UNKNOWN;

/**
* FSM for CircularSubparser module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers parsing logic.
* :input arg_parser_done: Argument subparser done parsing.
* :input arg_parser_rdy: Argument subparser ready to accept triggers.
* :input arg_parser_success: Argument subparser succeeded parsing.
* :input arg_parser_newline: Argument subparser encountered newline.
* :input arg_too_big: Parsed argument is too big for the field.
* :output zero: Zero all buffers and flags.
* :output set_cmd: Set the 'cmd' field of the opcode.
* :output arg_title: Argument type to look for.
* :output arg_parser_trigger: Trigger the argument subparser.
* :output set_x: Set 'x' field of the opcode.
* :output set_y: Set 'y' field of the opcode.
* :output set_i: Set 'i' field of the opcode.
* :output set_j: Set 'j' field of the opcode.
* :output set_flags: Set the 'flags' field of the opcode.
* :output update_pos: Update current position.
* :output set_success: Set the 'success' flag.
* :output set_newline: Encountered newline while parsing.
* :output done: Done parsing.
* :output rdy: Ready to accept triggers.
*/
module CircularSubparser_FSM (
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
	output logic set_i,
	output logic set_j,
	output logic set_flags,
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
		PARSE_I_WAIT_RDY,
		PARSE_I_TRIGGER,
		PARSE_I_WAIT_DONE,
		PARSE_I_CHECK,
		SET_I,
		PARSE_J_WAIT_RDY,
		PARSE_J_TRIGGER,
		PARSE_J_WAIT_DONE,
		PARSE_J_CHECK,
		SET_J,
		SET_FLAGS,
		UPDATE_POS,
		HANDLE_ARG_TOO_BIG,
		SET_NEWLINE_AND_CONTINUE,
		SET_NEWLINE_AND_HANDLE_ARG_TOO_BIG,
		SET_NEWLINE_AND_FAIL,
		SET_SUCCESS,
		DONE
	} CircularSubparser_state;

	CircularSubparser_state _cur_state;
	CircularSubparser_state _nxt_state;

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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_success & !arg_parser_newline & !arg_too_big) begin
				_nxt_state = SET_Y;
			end
			else if (arg_parser_newline) begin
				_nxt_state = SET_NEWLINE_AND_FAIL;
			end
		end
		SET_Y: begin
			_nxt_state = PARSE_I_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_Y;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 1;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		PARSE_I_WAIT_RDY: begin
			_nxt_state = PARSE_I_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_I;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_rdy) begin
				_nxt_state = PARSE_I_TRIGGER;
			end
		end
		PARSE_I_TRIGGER: begin
			_nxt_state = PARSE_I_TRIGGER;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_I;
			arg_parser_trigger = 1;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (!arg_parser_rdy) begin
				_nxt_state = PARSE_I_WAIT_DONE;
			end
		end
		PARSE_I_WAIT_DONE: begin
			_nxt_state = PARSE_I_WAIT_DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_I;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_done) begin
				_nxt_state = PARSE_I_CHECK;
			end
		end
		PARSE_I_CHECK: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_I;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_success & !arg_parser_newline) begin
				_nxt_state = SET_I;
				if (arg_too_big) begin
					_nxt_state = HANDLE_ARG_TOO_BIG;
				end
			end
			else if (arg_parser_newline) begin
				_nxt_state = SET_NEWLINE_AND_FAIL;
			end
		end
		SET_I: begin
			_nxt_state = PARSE_J_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_I;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 1;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		PARSE_J_WAIT_RDY: begin
			_nxt_state = PARSE_J_WAIT_RDY;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_J;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_rdy) begin
				_nxt_state = PARSE_J_TRIGGER;
			end
		end
		PARSE_J_TRIGGER: begin
			_nxt_state = PARSE_J_TRIGGER;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_J;
			arg_parser_trigger = 1;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (!arg_parser_rdy) begin
				_nxt_state = PARSE_J_WAIT_DONE;
			end
		end
		PARSE_J_WAIT_DONE: begin
			_nxt_state = PARSE_J_WAIT_DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_J;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_done) begin
				_nxt_state = PARSE_J_CHECK;
			end
		end
		PARSE_J_CHECK: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_J;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;

			if (arg_parser_success & arg_parser_newline) begin
				_nxt_state = SET_NEWLINE_AND_CONTINUE;
				if (arg_too_big) begin
					_nxt_state = SET_NEWLINE_AND_HANDLE_ARG_TOO_BIG;
				end
			end
			else if (arg_parser_success) begin
				_nxt_state = SET_J;
				if (arg_too_big) begin
					_nxt_state = HANDLE_ARG_TOO_BIG;
				end
			end
			else if (arg_parser_newline) begin
				_nxt_state = SET_NEWLINE_AND_FAIL;
			end
		end
		SET_J: begin
			_nxt_state = SET_FLAGS;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_J;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 1;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		SET_FLAGS: begin
			_nxt_state = UPDATE_POS;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 1;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 1;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		HANDLE_ARG_TOO_BIG: begin
			_nxt_state = UPDATE_POS;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 1;
			set_j = 1;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 0;
			done = 0;
			rdy = 0;
		end
		SET_NEWLINE_AND_CONTINUE: begin
			_nxt_state = SET_J;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 0;
			set_j = 0;
			set_flags = 0;
			update_pos = 0;
			set_success = 0;
			set_newline = 1;
			done = 0;
			rdy = 0;
		end
		SET_NEWLINE_AND_HANDLE_ARG_TOO_BIG: begin
			_nxt_state = UPDATE_POS;
			zero = 0;
			set_cmd = 0;
			arg_title = CHAR_UNKNOWN;
			arg_parser_trigger = 0;
			set_x = 0;
			set_y = 0;
			set_i = 1;
			set_j = 1;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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
			set_i = 0;
			set_j = 0;
			set_flags = 0;
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

endmodule : CircularSubparser_FSM
