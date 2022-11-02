`include "../../../src/common/common.svh"
`include "../../../src/processor/servo.svh"

import Servo_p::ServoPosition_t;

module ServoCtrl_tb;

	localparam PERIOD_BITS = `BYTE_BITS;

	reg clk;
	reg reset;
	Servo_p::ServoPosition_t pos;

	wire out;
	wire clk_en;

	ClockEnabler #(
		.PERIOD_BITS(`SERVO_CLK_EN_BITS)
	) clk_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(`SERVO_CLK_EN),
		.out(clk_en)
	);

	ServoCtrl #(
		.PERIOD_BITS(PERIOD_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.pos(pos),
		.out(out)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 8_000_002 clks
	initial begin
		reset = 1;
		pos = Servo_p::SERVO_POS_DOWN;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		#(`CLOCK_PERIOD * `SERVO_CLK_EN * `SERVO_PERIOD * 4);

		pos = Servo_p::SERVO_POS_UP;
		#(`CLOCK_PERIOD * `SERVO_CLK_EN * `SERVO_PERIOD * 4);
	end

endmodule : ServoCtrl_tb
