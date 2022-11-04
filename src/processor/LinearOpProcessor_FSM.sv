typedef enum {
	LINEAR_OP_PROC_STANDBY,
	LINEAR_OP_PROC_WAIT_DONE
} LinearOpProcessor_state;

/**
* FSM for Linear Opcode Processing unit.
* 
* :input clk: The clock of the system.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input trigger_in: Triggers this module (comes from OP field processing unit).
* :input done_in: Motor control units are done.
* :output trigger_out: Triggers the motor control units.
* :output done_out: Signals the parent unit that the operation of this module is finished.
*/
module LinearOpProcessor_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,

	input logic trigger_in,
	input logic done_in,

	output logic trigger_out,
	output logic done_out
);

	LinearOpProcessor_state cur_state;
	LinearOpProcessor_state nxt_state;

	always_comb begin
		trigger_out = 0;
		done_out = 0;
		case (cur_state)
			LINEAR_OP_PROC_STANDBY: begin
				nxt_state = LINEAR_OP_PROC_STANDBY;
				done_out = 1;
				if (trigger_in) begin
					done_out = 0; // To prevent races with parent
					trigger_out = 1;
					nxt_state = LINEAR_OP_PROC_WAIT_DONE;
				end
			end

			LINEAR_OP_PROC_WAIT_DONE: begin
				nxt_state = LINEAR_OP_PROC_WAIT_DONE;
				if (done_in) begin
					done_out = 1;
					nxt_state = LINEAR_OP_PROC_STANDBY;
				end
			end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			cur_state <= LINEAR_OP_PROC_STANDBY;
		end
		else if (clk_en) begin
			cur_state <= nxt_state;
		end
		else begin
			cur_state <= cur_state;
		end
	end // always_ff

endmodule : LinearOpProcessor_FSM
