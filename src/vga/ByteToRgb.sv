`include "common/common.svh"

/**
* Converts a byte into 3 distinct RGB signals - each bit duplicates into
* a full nibble.
*
* :input byte_in: A byte in the "xxrrggbb" format.
* :output r_out: Red signal.
* :output g_out: Green signal.
* :output b_out: Blue signal.
*/
module ByteToRgb (
	input logic [`BYTE_BITS-1:0] byte_in,
	output logic [`BYTE_BITS-1:0] r_out,
	output logic [`BYTE_BITS-1:0] g_out,
	output logic [`BYTE_BITS-1:0] b_out
);

	assign r_out = {{4{byte_in[5]}}, {4{byte_in[4]}}};
	assign g_out = {{4{byte_in[3]}}, {4{byte_in[2]}}};
	assign b_out = {{4{byte_in[1]}}, {4{byte_in[0]}}};

endmodule : ByteToRgb
