import Char_PKG::Char_t;
import Char_PKG::CHAR_NUM;
import Char_PKG::CHAR_MINUS;
import Char_PKG::CHAR_WHITESPACE;
import Char_PKG::CHAR_DOT;
import Char_PKG::CHAR_NEWLINE;

module ArgSubparser_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input Char_t char_type,
	input Char_t arg_title,
	input logic rd_done,
	input logic rd_rdy,
	input logic is_empty,
	input logic is_valid,

	output logic done,
	output logic rdy,
	output logic rd_trigger,
	output logic set_success,
	output logic set_too_big,
	output logic advance_num,
	output logic advance_precise_num,
	output logic set_negative,
	output logic zero,
	output logic store
);

	typedef enum {
		IDLE,
		TITLE_WAIT_RDY,
		TITLE_TRIGGER,
		TITLE_WAIT_DONE,
		TITLE_CHECK,
		SIGN_WAIT_RDY,
		SIGN_TRIGGER,
		SIGN_WAIT_DONE,
		SIGN_CHECK,
		SET_NEGATIVE,
		NUM_WAIT_RDY,
		NUM_TRIGGER,
		NUM_WAIT_DONE,
		NUM_CHECK,
		NUM_ADVANCE,
		NUM_IS_VALID,
		SET_TOO_BIG,
		PRECISE_NUM_WAIT_RDY,
		PRECISE_NUM_TRIGGER,
		PRECISE_NUM_WAIT_DONE,
		PRECISE_NUM_CHECK,
		PRECISE_NUM_ADVANCE,
		SET_SUCCESS,
		DONE
	} ArgSubparser_state;

	ArgSubparser_state _cur_state;
	ArgSubparser_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 1;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 1;

			if (trigger) begin
				_nxt_state = TITLE_WAIT_RDY;
				done = 0;
			end
		end
		TITLE_WAIT_RDY: begin
			_nxt_state = TITLE_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 1;
			store = 1;

			if (rd_rdy & !is_empty) begin
				_nxt_state = TITLE_TRIGGER;
			end
		end
		TITLE_TRIGGER: begin
			_nxt_state = TITLE_TRIGGER;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = TITLE_WAIT_DONE;
			end
		end
		TITLE_WAIT_DONE: begin
			_nxt_state = TITLE_WAIT_DONE;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = TITLE_CHECK;
			end
		end
		TITLE_CHECK: begin
			_nxt_state = TITLE_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (char_type == arg_title) begin
				_nxt_state = SIGN_WAIT_RDY;
			end

			if (char_type == CHAR_NEWLINE) begin
				_nxt_state = DONE;
				done = 1;
			end
		end
		SIGN_WAIT_RDY: begin
			_nxt_state = SIGN_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 1;

			if (rd_rdy & !is_empty) begin
				_nxt_state = SIGN_TRIGGER;
			end
		end
		SIGN_TRIGGER: begin
			_nxt_state = SIGN_TRIGGER;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = SIGN_WAIT_DONE;
			end
		end
		SIGN_WAIT_DONE: begin
			_nxt_state = SIGN_WAIT_DONE;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = SIGN_CHECK;
			end
		end
		SIGN_CHECK: begin
			_nxt_state = DONE;
			done = 1;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (char_type == CHAR_WHITESPACE) begin
				_nxt_state = SIGN_WAIT_RDY;
				done = 0;
			end
			else if (char_type == CHAR_MINUS) begin
				_nxt_state = SET_NEGATIVE;
				done = 0;
			end
			else if (char_type == CHAR_DOT) begin
				_nxt_state = PRECISE_NUM_WAIT_RDY;
				done = 0;
			end
			else if (char_type == CHAR_NUM) begin
				_nxt_state = NUM_CHECK;
				done = 0;
			end
		end
		SET_NEGATIVE: begin
			_nxt_state = NUM_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 1;
			zero = 0;
			store = 0;
		end
		NUM_WAIT_RDY: begin
			_nxt_state = NUM_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 1;

			if (rd_rdy & !is_empty) begin
				_nxt_state = NUM_TRIGGER;
			end
		end
		NUM_TRIGGER: begin
			_nxt_state = NUM_TRIGGER;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = NUM_WAIT_DONE;
			end
		end
		NUM_WAIT_DONE: begin
			_nxt_state = NUM_WAIT_DONE;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = NUM_CHECK;
			end
		end
		NUM_CHECK: begin
			_nxt_state = DONE;
			done = 1;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (char_type == CHAR_NUM) begin
				_nxt_state = NUM_ADVANCE;
				done = 0;
			end
			else if (char_type == CHAR_DOT) begin
				_nxt_state = PRECISE_NUM_WAIT_RDY;
				done = 0;
			end
			else if (char_type == CHAR_WHITESPACE) begin
				_nxt_state = SET_SUCCESS;
				done = 0;
			end
			else if (char_type == CHAR_NEWLINE) begin
				_nxt_state = SET_SUCCESS;
				done = 0;
			end
		end
		NUM_ADVANCE: begin
			_nxt_state = NUM_IS_VALID;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 1;
			advance_precise_num = 1;
			set_negative = 0;
			zero = 0;
			store = 0;
		end
		NUM_IS_VALID: begin
			_nxt_state = NUM_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (!is_valid) begin
				_nxt_state = SET_TOO_BIG;
			end
		end
		SET_TOO_BIG: begin
			_nxt_state = SET_SUCCESS;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 1;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;
		end
		PRECISE_NUM_WAIT_RDY: begin
			_nxt_state = PRECISE_NUM_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 1;

			if (rd_rdy & !is_empty) begin
				_nxt_state = PRECISE_NUM_TRIGGER;
			end
		end
		PRECISE_NUM_TRIGGER: begin
			_nxt_state = PRECISE_NUM_TRIGGER;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = PRECISE_NUM_WAIT_DONE;
			end
		end
		PRECISE_NUM_WAIT_DONE: begin
			_nxt_state = PRECISE_NUM_WAIT_DONE;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = PRECISE_NUM_CHECK;
			end
		end
		PRECISE_NUM_CHECK: begin
			_nxt_state = DONE;
			done = 1;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;

			if (char_type == CHAR_NUM) begin
				_nxt_state = PRECISE_NUM_ADVANCE;
				done = 0;
			end
			else if (char_type == CHAR_WHITESPACE) begin
				_nxt_state = SET_SUCCESS;
				done = 0;
			end
			else if (char_type == CHAR_NEWLINE) begin
				_nxt_state = SET_SUCCESS;
				done = 0;
			end
		end
		PRECISE_NUM_ADVANCE: begin
			_nxt_state = PRECISE_NUM_WAIT_RDY;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 1;
			set_negative = 0;
			zero = 0;
			store = 0;
		end
		SET_SUCCESS: begin
			_nxt_state = DONE;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 1;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			set_too_big = 0;
			advance_num = 0;
			advance_precise_num = 0;
			set_negative = 0;
			zero = 0;
			store = 0;
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

endmodule : ArgSubparser_FSM
