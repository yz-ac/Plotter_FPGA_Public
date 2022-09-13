`include "../../../src/common/common.svh"

module StepperCtrlXY_tb;

	localparam CLK_EN_BITS = `BYTE_BITS;
	localparam COUNT_BITS_X = `BYTE_BITS;
	localparam COUNT_BITS_Y = `BYTE_BITS;

	reg clk;
	reg reset;
	reg trigger;
	reg [COUNT_BITS_X-1:0] num_steps_x;
	reg [COUNT_BITS_Y-1:0] num_steps_y;

	wire clk_en;
	wire out_x;
	wire dir_x;
	wire out_y;
	wire dir_y;
	wire done;

	ClockEnabler #(
		.PERIOD_BITS(CLK_EN_BITS)
	) clk_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(2),
		.out(clk_en)
	);

	StepperCtrlXY #(
		.COUNT_BITS_X(COUNT_BITS_X),
		.COUNT_BITS_Y(COUNT_BITS_Y)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.num_steps_x(num_steps_x),
		.num_steps_y(num_steps_y),
		.out_x(out_x),
		.dir_x(dir_x),
		.out_y(out_y),
		.dir_y(dir_y),
		.done(done)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 198 clks
	initial begin
		reset = 1;
		trigger = 0;
		num_steps_x = 2;
		num_steps_y = 3;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 19)

		num_steps_x = 0;
		num_steps_y = -3;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 17);

		num_steps_x = -2;
		num_steps_y = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 11);

		num_steps_x = 0;
		num_steps_y = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		num_steps_x = -7;
		num_steps_y = 4;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 129);
	end

endmodule : StepperCtrlXY_tb
