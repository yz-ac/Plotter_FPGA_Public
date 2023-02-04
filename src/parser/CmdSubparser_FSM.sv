import Char_PKG::Char_t;
import Char_PKG::CHAR_G;
import Char_PKG::CHAR_NUM;

/**
* FSM for CmdSubparser.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers parsing logic.
* :input char_type: Type of the last read character.
* :input rd_done: Done reading character.
* :input rd_rdy: Reader is ready to accept triggers.
* :input is_empty: No more data can be read.
* :input is_valid: Is command valid.
* :output done: Done parsing.
* :output rdy: Ready to accept triggers.
* :output rd_trigger: Trigger character read.
* :output set_success: Set success flag for parsing.
* :output advance_num: Update number buffer with new digit.
* :output zero: Zero all buffers and reset success state.
* :output store: Store last char.
*/
module CmdSubparser_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input Char_t char_type,
	input logic rd_done,
	input logic rd_rdy,
	input logic is_empty,
	input logic is_valid,

	output logic done,
	output logic rdy,
	output logic rd_trigger,
	output logic set_success,
	output logic advance_num,
	output logic zero,
	output logic store
);

	typedef enum {
		IDLE,
		CODE_TRIGGER,
		CODE_WAIT,
		CODE_CHECK,
		WAIT_RD_RDY_1,
		NUM_TRIGGER_1,
		NUM_WAIT_1,
		NUM_ADVANCE_1,
		WAIT_RD_RDY_2,
		NUM_TRIGGER_2,
		NUM_WAIT_2,
		NUM_ADVANCE_2,
		NUM_CHECK,
		SET_SUCCESS,
		DONE
	} CmdSubparser_state;

	CmdSubparser_state _cur_state;
	CmdSubparser_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 1;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 1;

			if (trigger & rd_rdy & !is_empty) begin
				_nxt_state = CODE_TRIGGER;
				done = 0;
			end
		end
		CODE_TRIGGER: begin
			_nxt_state = CODE_TRIGGER;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			advance_num = 0;
			zero = 1;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = CODE_WAIT;
			end
		end
		CODE_WAIT: begin
			_nxt_state = CODE_WAIT;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = CODE_CHECK;
			end
		end
		CODE_CHECK: begin
			_nxt_state = WAIT_RD_RDY_1;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (char_type != CHAR_G) begin
				_nxt_state = DONE;
				done = 1;
			end
		end
		WAIT_RD_RDY_1: begin
			_nxt_state = WAIT_RD_RDY_1;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 1;

			if (rd_rdy & !is_empty) begin
				_nxt_state = NUM_TRIGGER_1;
			end
		end
		NUM_TRIGGER_1: begin
			_nxt_state = NUM_TRIGGER_1;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = NUM_WAIT_1;
			end
		end
		NUM_WAIT_1: begin
			_nxt_state = NUM_WAIT_1;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = NUM_ADVANCE_1;
			end
		end
		NUM_ADVANCE_1: begin
			_nxt_state = WAIT_RD_RDY_2;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 1;
			zero = 0;
			store = 0;

			if (char_type != CHAR_NUM) begin
				_nxt_state = DONE;
				done = 1;
			end
		end
		WAIT_RD_RDY_2: begin
			_nxt_state = WAIT_RD_RDY_2;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 1;

			if (rd_rdy & !is_empty) begin
				_nxt_state = NUM_TRIGGER_2;
			end
		end
		NUM_TRIGGER_2: begin
			_nxt_state = NUM_TRIGGER_2;
			done = 0;
			rdy = 0;
			rd_trigger = 1;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (!rd_rdy) begin
				_nxt_state = NUM_WAIT_2;
			end
		end
		NUM_WAIT_2: begin
			_nxt_state = NUM_WAIT_2;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (rd_done) begin
				_nxt_state = NUM_ADVANCE_2;
			end
		end
		NUM_ADVANCE_2: begin
			_nxt_state = NUM_CHECK;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 1;
			zero = 0;
			store = 0;

			if (char_type != CHAR_NUM) begin
				_nxt_state = DONE;
				done = 1;
			end
		end
		NUM_CHECK: begin
			_nxt_state = DONE;
			done = 1;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;

			if (is_valid) begin
				_nxt_state = SET_SUCCESS;
				done = 0;
			end
		end
		SET_SUCCESS: begin
			_nxt_state = DONE;
			done = 0;
			rdy = 0;
			rd_trigger = 0;
			set_success = 1;
			advance_num = 0;
			zero = 0;
			store = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 0;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;
		end
		endcase
		default: begin
			_nxt_state = IDLE;
			done = 1;
			rdy = 1;
			rd_trigger = 0;
			set_success = 0;
			advance_num = 0;
			zero = 0;
			store = 0;
		end
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

endmodule : CmdSubparser_FSM
