`include "tb/simulation.svh"
`include "common/common.svh"
`include "peripherals/peripherals.svh"

module StepperCtrlXY_tb;
	int fd;

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
		TB_BAD,
		TB_TEST_1,
		TB_TEST_2,
		TB_TEST_3,
		TB_TEST_4
	} StepperCtrlXY_tb_test;

	StepperCtrlXY_tb_test _test;

	always_ff @(negedge reset) begin
		_test <= TB_TEST_1;
		intf.master.pulse_num_x <= 0;
		intf.master.pulse_num_y <= 0;
		intf.master.trigger <= 1;
	end

	always_ff @(negedge intf.master.rdy) begin
		intf.master.trigger <= 0;
	end

	always_ff @(posedge intf.master.rdy) begin
		case (_test)
		TB_TEST_1: begin
			intf.master.pulse_num_x <= -3;
			intf.master.trigger <= 1;
			_test <= TB_TEST_2;
		end
		TB_TEST_2: begin
			intf.master.pulse_num_y <= 2;
			intf.master.trigger <= 1;
			_test <= TB_TEST_3;
		end
		TB_TEST_3: begin
			intf.master.pulse_num_x <= 0;
			intf.master.trigger <= 1;
			_test <= TB_TEST_4;
		end
		TB_TEST_4: begin
			`FCLOSE
			`STOP
		end
		default: begin
			intf.master.trigger <= 0;
			intf.master.pulse_num_x <= 0;
			intf.master.pulse_num_y <= 0;
			_test <= TB_BAD;
		end
		endcase
	end

	always_ff @(posedge out_x) begin
		`FWRITE(("time: %t, X, test: %d, dir: %d", $time, _test, dir_x))
	end

	always_ff @(posedge out_y) begin
		`FWRITE(("time: %t, Y, test: %d, dir: %d", $time, _test, dir_y))
	end

	initial begin
		`FOPEN("tests/tests/StepperCtrlXY_tb.txt")

		intf.master.pulse_width = `STEPPER_PULSE_WIDTH;
		intf.master.trigger = 0;
		intf.master.pulse_num_x = 0;
		intf.master.pulse_num_y = 0;
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
	end

endmodule : StepperCtrlXY_tb
