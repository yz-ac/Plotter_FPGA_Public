`include "../../../src/common/common.svh"

`define CLOCK_DIVIDE (50_000_000)
// `define CLOCK_DIVIDE (50)

typedef enum {
	STEPPER_CTRL_XY_TOP_WAIT,
	STEPPER_CTRL_XY_TOP_TRIGGER,
	STEPPER_CTRL_XY_TOP_STOP
} StepperCtrlXY_top_state;

module StepperCtrlXY_top (
	input logic clk,
	input logic reset,
	output logic out_x,
	output logic dir_x,
	output logic out_y,
	output logic dir_y,
	output logic done_out
);

	localparam COUNT_BITS_X = `BYTE_BITS;
	localparam COUNT_BITS_Y = `BYTE_BITS;
	localparam STATE_BITS = `BYTE_BITS;

	reg clk_en;
	reg trigger;
	reg [COUNT_BITS_X-1:0] num_steps_x;
	reg [COUNT_BITS_Y-1:0] num_steps_y;
	reg [COUNT_BITS_X-1:0] saved_num_steps_x;
	reg [COUNT_BITS_Y-1:0] saved_num_steps_y;

	reg [STATE_BITS-1:0] state_counter;
	reg increase_counter;

	wire done;

	StepperCtrlXY_top_state cur_state;
	StepperCtrlXY_top_state nxt_state;

	ClockEnabler #(
		.PERIOD_BITS(`DWORD_BITS)
	) clock_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(`CLOCK_DIVIDE),
		.out(clk_en)
	);

	StepperCtrlXY #(
		.COUNT_BITS_X(COUNT_BITS_X),
		.COUNT_BITS_Y(COUNT_BITS_Y)
	) stepper_ctrl_xy (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.num_steps_x(saved_num_steps_x),
		.num_steps_y(saved_num_steps_y),
		.out_x(out_x),
		.dir_x(dir_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.done(done)
	);

	assign done_out = done;

	always_comb begin
		num_steps_x = 0;
		num_steps_y = 0;
		increase_counter = 0;
		trigger = 0;

		case (cur_state)
			STEPPER_CTRL_XY_TOP_WAIT: begin
				nxt_state = STEPPER_CTRL_XY_TOP_WAIT;
				if (done) begin
					nxt_state = STEPPER_CTRL_XY_TOP_TRIGGER;
					increase_counter = 1;
					case (state_counter)
						0: begin
							num_steps_x = 2;
							num_steps_y = 3;
						end
						1: begin
							num_steps_x = 0;
							num_steps_y = -5;
						end
						2: begin
							num_steps_x = -7;
							num_steps_y = 4;
						end
						3: begin
							num_steps_x = -2;
							num_steps_y = 0;
						end
						4: begin
							num_steps_x = 0;
							num_steps_y = 0;
						end
						default: begin
							num_steps_x = 0;
							num_steps_y = 0;
							nxt_state = STEPPER_CTRL_XY_TOP_STOP;
						end
					endcase
				end
			end

			STEPPER_CTRL_XY_TOP_TRIGGER: begin
				trigger = 1;
				nxt_state = STEPPER_CTRL_XY_TOP_WAIT;
			end

			STEPPER_CTRL_XY_TOP_STOP: begin
				nxt_state = STEPPER_CTRL_XY_TOP_STOP;
			end
		endcase
	end

	always_ff @(posedge clk) begin
		if (reset) begin
			cur_state <= STEPPER_CTRL_XY_TOP_WAIT;
			state_counter <= 0;
			saved_num_steps_x <= 0;
			saved_num_steps_y <= 0;
		end
		else if (clk_en) begin
			cur_state <= nxt_state;
			state_counter <= state_counter;
			saved_num_steps_x <= saved_num_steps_x;
			saved_num_steps_y <= saved_num_steps_y;
			if (increase_counter) begin
				state_counter <= state_counter + 1;
				saved_num_steps_x <= num_steps_x;
				saved_num_steps_y <= num_steps_y;
			end
		end
		else begin
			cur_state <= cur_state;
			state_counter <= state_counter;
			saved_num_steps_x <= saved_num_steps_x;
			saved_num_steps_y <= saved_num_steps_y;
		end
	end

endmodule : StepperCtrlXY_top
