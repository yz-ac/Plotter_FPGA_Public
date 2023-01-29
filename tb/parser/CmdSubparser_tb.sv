`include "tb/simulation.svh"
`include "common/common.svh"

module CmdSubparser_tb;
	int fd;

	wire clk;
	reg reset;
	Subparser_IF sub_intf ();
	reg [`BYTE_BITS-1:0] char_in;
	wire [`OP_CMD_BITS-1:0] cmd;

	SimClock sim_clk (
		.out(clk)
	);

	FifoBuffer #(
		.ROWS(9),
		.COLS(`BYTE_BITS),
		.INIT_FILE("data/cmd_subparser_tb.mem"),
		.PRELOADED_ROWS(9)
	) fifo_buf (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.rd_trigger(sub_intf.master.rd_trigger),
		.wr_trigger(0),
		.wr_data(0),
		.rd_data(char_in),
		.is_empty(sub_intf.master.is_empty),
		.is_full(),
		.rd_done(sub_intf.master.rd_done),
		.rd_rdy(sub_intf.master.rd_rdy),
		.wr_done(),
		.wr_rdy()
	);

	CmdSubparser UUT (
		.clk(clk),
		.reset(reset),
		.clk_en(1),
		.sub_intf(sub_intf.slave),
		.char_in(char_in),
		.cmd(cmd)
	);

	always_ff @(negedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 0;
	end

	always_ff @(posedge sub_intf.master.rdy) begin
		sub_intf.master.trigger <= 1;
	end

	always_ff @(posedge sub_intf.master.rd_trigger or posedge sub_intf.slave.rd_done) begin
		`FWRITE(("time: %t, char_in: %d, cmd: %d, success: %d", $time, char_in, cmd, sub_intf.master.success))
	end

	always_ff @(posedge sub_intf.master.done) begin
		if (sub_intf.slave.is_empty) begin
			`FCLOSE
			`STOP
		end
	end

	initial begin
		`FOPEN("tests/tests/CmdSubparser_tb.txt")

		sub_intf.master.trigger = 0;
		reset = 1;
		#(`CLOCK_PERIOD * 2);

		reset = 0;
		sub_intf.master.trigger = 1;

	end // initial

endmodule : CmdSubparser_tb
