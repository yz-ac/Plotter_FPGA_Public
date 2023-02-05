/**
* FSM for Dummy Subparser module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger: Triggers parsing logic.
* :output zero: Zero all buffers and flags.
* :output set_cmd: Set 'cmd' field in parser opcode.
* :output set_success: Set 'success' flag.
* :output done: Done parsing.
* :output rdy: Ready to accept triggers.
*/
module DummySubparser_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,

	output logic zero,
	output logic set_cmd,
	output logic set_success,
	output logic done,
	output logic rdy
);

	typedef enum {
		IDLE,
		ZERO,
		SET_CMD_AND_SUCCESS,
		DONE
	} DummySubparser_state;

	DummySubparser_state _cur_state;
	DummySubparser_state _nxt_state;

	always_comb begin
		case (_cur_state)
		IDLE: begin
			_nxt_state = IDLE;
			zero = 0;
			set_cmd = 0;
			set_success = 0;
			done = 1;
			rdy = 1;

			if (trigger) begin
				_nxt_state = ZERO;
				done = 0;
			end
		end
		ZERO: begin
			_nxt_state = SET_CMD_AND_SUCCESS;
			zero = 1;
			set_cmd = 0;
			set_success = 0;
			done = 0;
			rdy = 0;
		end
		SET_CMD_AND_SUCCESS: begin
			_nxt_state = DONE;
			zero = 0;
			set_cmd = 1;
			set_success = 1;
			done = 0;
			rdy = 0;
		end
		DONE: begin
			_nxt_state = IDLE;
			zero = 0;
			set_cmd = 0;
			set_success = 0;
			done = 1;
			rdy = 0;
		end
		default: begin
			_nxt_state = IDLE;
			zero = 0;
			set_cmd = 0;
			set_success = 0;
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

endmodule : DummySubparser_FSM
