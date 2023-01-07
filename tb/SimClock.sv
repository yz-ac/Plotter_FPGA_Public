`include "tb/simulation.svh"

module SimClock (
	output logic out
);

	always begin
		out = 1;
		#(`CLOCK_PERIOD / 2);
		out = 0;
		#(`CLOCK_PERIOD / 2);
	end // always

endmodule : SimClock
