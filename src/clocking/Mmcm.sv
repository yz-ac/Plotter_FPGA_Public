`include "clocking/clocking.svh"

`ifdef SIM_DEBUG

// Nothing here - we just set the master clock to the required frequency
// in the simulation.
	
`else // SIM_DEBUG

/**
* Wrapper around the MMCM primitive - uses only the first clock (see UG472 for
* full description).
*
* :param CLK_MULT: Frequency multiplier (see UG472).
* :param CLK_DIV: Frequency divider (see UG472).
* :input clk_in: Input clock (master clock).
* :output clk_out: Output clock.
*/
module Mmcm #(
	parameter CLK_MULT = `CLKOUT_MULT_F,
	parameter CLK_DIV = `CLKOUT_DIV_F
)
(
	input logic clk_in,
	output logic clk_out
);

	wire _buf_clk_feedback;
	wire _clk_feedback;
	wire _clk_out;

	MMCME2_ADV #(
		.CLKFBOUT_MULT_F(CLK_MULT),
		.CLKOUT0_DIVIDE_F(CLK_DIV)
	) _mmcm (
		.CLKFBIN(_buf_clk_feedback),
		.CLKIN1(clk_in),

		.CLKFBOUT(_clk_feedback),
		.CLKOUT0(_clk_out)
	);

	BUFG _feedback_buf (
		.I(_clk_feedback),
		.O(_buf_clk_feedback)
	);

	BUFG _output_buf (
		.I(_clk_out),
		.O(clk_out)
	);

endmodule : Mmcm

`endif // SIM_DEBUG
