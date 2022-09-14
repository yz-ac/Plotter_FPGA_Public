`include "./common.svh"

/**
* Simple counter.
* 
* :param COUNTER_BITS: Number of bits in the counter, counting any further will overflow.
* :input clk: System clock.
* :input reset: Resets the counter.
* :input clk_en: Slow clock enabling the module.
* :input enable: Enables counting.
* :input start_from_one: Start counting from 1 and not from 0.
* :output out: The value of the counter.
*/
module Counter #(
	COUNTER_BITS = `BYTE_BITS
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic enable,
	input logic start_from_one,
	output logic [COUNTER_BITS-1:0] out
);

	reg [COUNTER_BITS-1:0] count;

	assign out = count;

	always_ff @(posedge clk) begin
		if (reset) begin
			count <= 0;
			if (start_from_one) begin
				count <= 1;
			end
		end
		else if (clk_en) begin
			count <= count + enable;
			// Overflow to 1 if requested.
			if ((~|(count + enable)) & start_from_one) begin
				count <= 1;
			end
		end
		else begin
			count <= count;
		end
	end

endmodule : Counter
