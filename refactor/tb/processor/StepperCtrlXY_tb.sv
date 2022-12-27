`include "tb/simulation.svh"
`include "common/common.svh"
`include "processor/processor.svh"

module StepperCtrlXY_tb;

	localparam DIV_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire clk_en;
	wire out_x;
	wire dir_x;
	wire out_y;
	wire dir_y;

	StepperCtrlXY_IF #(
		.PULSE_NUM_X_BITS(`STEPPER_PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(`STEPPER_PULSE_NUM_Y_BITS),
		.PULSE_WIDTH_BITS(`STEPPER_PULSE_WIDTH_BITS)
	) intf ();

	SimClock sim_clk (
		.out(clk)
	);

	FreqDivider #(
		.DIV_BITS(DIV_BITS)
	) freq_div (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.en(1),
		.div(2),
		.out(clk_en)
	);

	StepperCtrlXY UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(intf.slave),
		.out_x(out_x),
		.dir_x(dir_x),
		.out_y(out_y),
		.dir_y(dir_y)
	);

	typedef enum {
		TB_IDLE,
		TB_TRIGGER_1,
		TB_RDY_1,
		TB_TRIGGER_2,
		TB_RDY_2,
		TB_TRIGGER_3,
		TB_RDY_3,
		TB_TRIGGER_4,
		TB_RDY_4,
		TB_DONE
	} StepperCtrlXY_tb_state;

	StepperCtrlXY_tb_state cur_state;
	StepperCtrlXY_tb_state nxt_state;

	always_ff @(posedge clk) begin
		if (reset) begin
			cur_state <= TB_IDLE;
		end
		else begin
			cur_state <= nxt_state;
		end
	end

	always_comb begin
		intf.master.trigger = 0;
		intf.master.pulse_width = `STEPPER_PULSE_WIDTH;
		intf.master.pulse_num_x = 0;
		intf.master.pulse_num_y = 0;
		case (cur_state)
		TB_IDLE: begin
			nxt_state = TB_TRIGGER_1;
		end
		TB_TRIGGER_1: begin
			nxt_state = TB_TRIGGER_1;
			intf.master.trigger = 1;
			if (intf.master.done == 0) begin
				nxt_state = TB_RDY_1;
			end
		end
		TB_RDY_1: begin
			nxt_state = TB_RDY_1;
			intf.master.trigger = 0;
			if (intf.master.rdy == 1) begin
				nxt_state = TB_TRIGGER_2;
			end
		end
		TB_TRIGGER_2: begin
			nxt_state = TB_TRIGGER_2;
			intf.master.trigger = 1;
			intf.master.pulse_num_x = -3;
			if (intf.master.done == 0) begin
				nxt_state = TB_RDY_2;
			end
		end
		TB_RDY_2: begin
			nxt_state = TB_RDY_2;
			intf.master.trigger = 0;
			intf.master.pulse_num_x = -3;
			if (intf.master.rdy == 1) begin
				nxt_state = TB_TRIGGER_3;
			end
		end
		TB_TRIGGER_3: begin
			nxt_state = TB_TRIGGER_3;
			intf.master.trigger = 1;
			intf.master.pulse_num_x = -3;
			intf.master.pulse_num_y = 2;
			if (intf.master.done == 0) begin
				nxt_state = TB_RDY_3;
			end
		end
		TB_RDY_3: begin
			nxt_state = TB_RDY_3;
			intf.master.trigger = 0;
			intf.master.pulse_num_x = -3;
			intf.master.pulse_num_y = 2;
			if (intf.master.rdy == 1) begin
				nxt_state = TB_TRIGGER_4;
			end
		end
		TB_TRIGGER_4: begin
			nxt_state = TB_TRIGGER_4;
			intf.master.trigger = 1;
			intf.master.pulse_num_x = 0;
			intf.master.pulse_num_y = 2;
			if (intf.master.done == 0) begin
				nxt_state = TB_RDY_4;
			end
		end
		TB_RDY_4: begin
			nxt_state = TB_RDY_4;
			intf.master.trigger = 0;
			intf.master.pulse_num_x = 0;
			intf.master.pulse_num_y = 2;
			if (intf.master.rdy == 1) begin
				nxt_state = TB_DONE;
			end
		end
		TB_DONE: begin
			$stop;
		end
		endcase
	end

	initial begin
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end

	// initial begin
	// 	reset = 1;
	// 	intf.master.trigger = 0;
	// 	intf.master.pulse_width = `STEPPER_PULSE_WIDTH;
	// 	intf.master.pulse_num_x = 0;
	// 	intf.master.pulse_num_y = 0;
	// 	#(`CLOCK_PERIOD * 2);

	// 	reset = 0;
	// 	intf.master.trigger = 1;
	// 	wait(_done_down == 1);

	// 	intf.master.trigger = 0;
	// 	wait(_rdy_up == 1);

	// 	intf.master.pulse_num_x = 3;
	// 	intf.master.trigger = 1;
	// 	wait(_done_down == 2);

	// 	intf.master.trigger = 0;
	// 	wait(_rdy_up == 2);

	// 	intf.master.pulse_num_y = 2;
	// 	intf.master.trigger = 1;
	// 	wait(_done_down == 3);

	// 	intf.master.trigger = 0;
	// 	wait(_rdy_up == 3);

	// 	intf.master.pulse_num_x = 0;
	// 	intf.master.trigger = 1;
	// 	wait(_done_down == 4);

	// 	intf.master.trigger = 0;
	// 	wait(_rdy_up == 4);

	// 	$stop;
	// end // initial

endmodule : StepperCtrlXY_tb
