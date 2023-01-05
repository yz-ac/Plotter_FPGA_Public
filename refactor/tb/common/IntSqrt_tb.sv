`include "tb/simulation.svh"
`include "common/common.svh"

module IntSqrt_tb;

	localparam NUM_BITS = `BYTE_BITS;

	wire clk;
	reg reset;
	reg [NUM_BITS-1:0] num_in;
	reg trigger;
	wire [NUM_BITS-1:0] sqrt_out;
	wire done;
	wire rdy;

	SimClock sim_clk (
		.out(clk)
	);

	IntSqrt #(
		.NUM_BITS(NUM_BITS)
	) UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.num_in(num_in),
		.trigger(trigger),
		.sqrt_out(sqrt_out),
		.done(done),
		.rdy(rdy)
	);

	initial begin
		reset = 1;
		trigger = 0;
		num_in = 0;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		num_in = 1;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 10);

		num_in = 9;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 20);

		num_in = 255;
		trigger = 1;
		#(`CLOCK_PERIOD * 2);

		trigger = 0;
		#(`CLOCK_PERIOD * 20);

		$stop;
	end // initial

endmodule : IntSqrt_tb
