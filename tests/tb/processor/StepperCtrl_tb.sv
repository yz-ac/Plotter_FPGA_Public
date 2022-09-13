`include "../../../src/common/common.svh"

module StepperCtrl_tb;

	localparam CLK_EN_BITS = `BYTE_BITS;
	localparam COUNT_BITS = `BYTE_BITS;
	localparam WIDTH_BITS = `BYTE_BITS;

	reg clk;
	reg reset;
	reg trigger;
	reg [COUNT_BITS-1:0] num_steps;
	reg [PULSE_WIDTH-1:0] pulse_width;

	wire clk_en;
	wire out;
	wire dir;
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

	StepperCtrl #(
		.COUNT_BITS(COUNT_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(trigger),
		.num_steps(num_steps),
		.pulse_width(pulse_width),
		.out(out),
		.dir(dir),
		.done(done)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 120 clks
	initial begin
		reset = 1;
		trigger = 0;
		num_steps = 3;
		pulse_width = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2)

		trigger = 0;
		#(`CLOCK_PERIOD * 17);

		trigger = 1;
		#(`CLOCK_PERIOD * 2)

		trigger = 0;
		#(`CLOCK_PERIOD * 7);

		trigger = 1;
		#(`CLOCK_PERIOD * 2)

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		num_steps = -5;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 29);

		num_steps = 3;
		pulse_width = 3;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 30)

		pulse_width = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 13);
		
	end

endmodule : StepperCtrl_tb
