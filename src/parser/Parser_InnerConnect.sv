`include "common/common.svh"

import Char_PKG::Char_t;
import Char_PKG::CHAR_G;
import Char_PKG::CHAR_NUM;
import Char_PKG::CHAR_X;
import Char_PKG::CHAR_Y;
import Char_PKG::CHAR_I;
import Char_PKG::CHAR_J;
import Char_PKG::CHAR_WHITESPACE;
import Char_PKG::CHAR_DOT;
import Char_PKG::CHAR_NEWLINE;
import Char_PKG::CHAR_UNKNOWN;


module Parser_InnerConnect (
	input logic [`BYTE_BITS-1:0] char_in,

	output Char_t char_type
);

	always_comb begin : __char_type
		if (char_in == 71) begin
			char_type = CHAR_G;
		end
		else if ((char_in >= 48) && (char_in <= 57)) begin
			char_type = CHAR_NUM;
		end
		else if (char_in == 88) begin
			char_type = CHAR_X;
		end
		else if (char_in == 89) begin
			char_type = CHAR_Y;
		end
		else if (char_in == 73) begin
			char_type = CHAR_I;
		end
		else if (char_in == 74) begin
			char_type = CHAR_J;
		end
		else if ((char_in == 9) | (char_in == 32)) begin
			char_type = CHAR_WHITESPACE;
		end
		else if (char_in == 46) begin
			char_type = CHAR_DOT;
		end
		else if (char_in == 10) begin
			char_type = CHAR_NEWLINE;
		end
		else begin
			char_type = CHAR_UNKNOWN;
		end
	end : __char_type

endmodule : Parser_InnerConnect
