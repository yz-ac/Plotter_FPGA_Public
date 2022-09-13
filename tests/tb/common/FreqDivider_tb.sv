`include "../../../src/common/common.svh"

module FreqDivider_tb;

	localparam DIV_BITS = `BYTE_BITS;
	localparam CLK_EN_BITS = `BYTE_BITS;

	reg clk;
	reg reset;
	reg [DIV_BITS-1:0] div_val;

	wire clk_en;
	wire signal_out;

	ClockEnabler #(
		.PERIOD_BITS(CLK_EN_BITS)
	) clk_enabler (
		.clk(clk),
		.reset(reset),
		.enable(1),
		.period(2),
		.out(clk_en)
	);

	FreqDivider #(
		.DIV_BITS(DIV_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.signal_in(clk_en),
		.div_val(div_val),
		.signal_out(signal_out)
	);

	always begin
		clk = 1'b1;
		#(`CLOCK_PERIOD / 2);
		clk = 1'b0;
		#(`CLOCK_PERIOD / 2);
	end

	// 96 clks
	initial begin
		reset = 1;
		div_val = 2;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		#(`CLOCK_PERIOD * 21);

		div_val = 5;
		#(`CLOCK_PERIOD * 53);
		
		div_val = 1;
		#(`CLOCK_PERIOD * 10);

		div_val = 0;
		#(`CLOCK_PERIOD * 10);
	end

endmodule : FreqDivider_tb
