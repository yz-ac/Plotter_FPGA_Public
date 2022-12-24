`include "tb/simulation.svh"
`include "common/common.svh"

module FreqDivider_tb;

	localparam DIV_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	reg en;
	reg [DIV_BITS-1:0] div;

	wire out;

	SimClock sim_clk (
		.out(clk)
	);

	FreqDivider #(
		.DIV_BITS(DIV_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.en(en),
		.div(div),
		.out(out)
	);

	initial begin
		reset = 1;
		en = 0;
		div = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		en = 1;
		#(`CLOCK_PERIOD * 4);

		div = 3;
		#(`CLOCK_PERIOD * 10);

		div = 5;
		#(`CLOCK_PERIOD * 10);

		en = 0;
		#(`CLOCK_PERIOD * 4);

		$stop;
	end // initial

endmodule : FreqDivider_tb
