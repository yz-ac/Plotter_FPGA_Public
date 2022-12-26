`include "common/common.svh"

module StepperCtrlXY (
	input logic clk,
	input logic reset,
	input logic clk_en,
	StepperCtrlXY_IF intf,
	output logic out_x,
	output logic dir_x,
	output logic out_y,
	output logic dir_y
);

	module ConnectXY (
		StepperCtrlXY_IF intf_xy,
		StepperCtrl_IF intf_x,
		StepperCtrl_IF intf_y
	);
		wire _done_x;
		wire _rdy_x;
		wire _done_y;
		wire _rdy_y;

		assign _done_x = intf_x.done;
		assign _rdy_x = intf_x.rdy;
		assign _done_y = intf_y.done;
		assign _rdy_y = intf_y.rdy;

		assign intf_x.pulse_num = intf_xy.pulse_num_x;
		assign intf_x.trigger = intf_xy.trigger;

		assign intf_y.pulse_num = intf_xy.pulse_num_y;
		assign intf_y.trigger = intf_xy.trigger;

		assign intf_xy.done = _done_x & _done_y;
		assign intf_xy.rdy = _rdy_x & _rdy_y;
	endmodule : ConnectXY

	module PulseWidthMult #(
		PULSE_NUM_X_BITS = `BYTE_BITS,
		PULSE_NUM_Y_BITS = `BYTE_BITS,
		PULSE_WIDTH_BITS = `BYTE_BITS
	)
	(
		input logic [PULSE_NUM_X_BITS-1:0] pulse_num_x,
		input logic [PULSE_NUM_Y_BITS-1:0] pulse_num_y,
		input logic [PULSE_WIDTH_BITS-1:0] pulse_width_in,
		output logic [PULSE_WIDTH_BITS+PULSE_NUM_Y_BITS-1:0] pulse_width_x_out,
		output logic [PULSE_WIDTH_BITS+PULSE_NUM_X_BITS-1:0] pulse_width_y_out
	);
		always_comb begin
			pulse_width_x_out = pulse_width_in * pulse_num_y;
			pulse_width_y_out = pulse_width_in * pulse_num_x;
			if ((~|pulse_num_x) | (~|pulse_num_y)) begin
				pulse_width_x_out = pulse_width_in;
				pulse_width_y_out = pulse_width_in;
			end
		end // always_comb
	endmodule : PulseWidthMult

	localparam PULSE_WIDTH_X_BITS = intf.PULSE_WIDTH_BITS + intf.PULSE_NUM_Y_BITS;
	localparam PULSE_WIDTH_Y_BITS = intf.PULSE_WIDTH_BITS + intf.PULSE_NUM_X_BITS;

	StepperCtrl_IF #(
		.PULSE_NUM_BITS(intf.PULSE_NUM_X_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_X_BITS)
	) _intf_x ();

	StepperCtrl_IF #(
		.PULSE_NUM_BITS(intf.PULSE_NUM_Y_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_Y_BITS)
	) _intf_y ();

	StepperCtrl _stepper_ctrl_x (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(_intf_x.slave),
		.out(out_x),
		.dir(dir_x)
	);

	StepperCtrl _stepper_ctrl_y (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(_intf_y.slave),
		.out(out_y),
		.dir(dir_y)
	);

	PulseWidthMult #(
		.PULSE_NUM_X_BITS(intf.PULSE_NUM_X_BITS),
		.PULSE_NUM_Y_BITS(intf.PULSE_NUM_Y_BITS),
		.PULSE_WIDTH_BITS(intf.PULSE_WIDTH_BITS)
	) _pulse_width_mult (
		.pulse_num_x(intf.pulse_num_x),
		.pulse_num_y(intf.pulse_num_y),
		.pulse_width_in(intf.pulse_width),
		.pulse_width_x_out(_intf_x.master.pulse_width),
		.pulse_width_y_out(_intf_y.master.pulse_width)
	);

	ConnectXY _connect_xy (
		.intf_xy(intf),
		.intf_x(_intf_x.master),
		.intf_y(_intf_y.master)
	);

endmodule : StepperCtrlXY
