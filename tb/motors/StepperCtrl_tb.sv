`include "tb/simulation.svh"
`include "common/common.svh"

module StepperCtrl_tb;
	int fd;

	localparam DIV_BITS = `BYTE_BITS;
	localparam PULSE_NUM_BITS = `BYTE_BITS;
	localparam PULSE_WIDTH_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	wire clk_en;

	wire out;
	wire dir;
	wire n_en;

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

	StepperCtrl_IF #(
		.PULSE_NUM_BITS(PULSE_NUM_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_BITS)
	) intf ();

	StepperCtrl UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(intf.slave),
		.out(out),
		.dir(dir),
		.n_en(n_en)
	);

	always_ff @(posedge out) begin
		`FWRITE(("time: %t, pulse_num: %d, pulse_width: %d, dir: %d", $time, intf.slave.pulse_num, intf.slave.pulse_width, dir))
	end

	initial begin
		`FOPEN("tests/tests/StepperCtrl_tb.txt")

		reset = 1;
		intf.master.trigger = 0;
		intf.master.pulse_num = 0;
		intf.master.pulse_width = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 4);

		intf.master.pulse_num = -4;
		intf.master.pulse_width = 2;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 40);

		intf.master.pulse_num = 2;
		intf.master.pulse_width = 3;
		intf.master.trigger = 1;
		#(`CLOCK_PERIOD * 2);

		intf.master.trigger = 0;
		#(`CLOCK_PERIOD * 30);

		`FCLOSE
		`STOP
	end // initial

endmodule : StepperCtrl_tb
