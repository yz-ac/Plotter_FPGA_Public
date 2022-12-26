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

	localparam PULSE_WIDTH_X_BITS = intf.PULSE_WIDTH_BITS + intf.PULSE_NUM_Y_BITS - 1 - 1;
	localparam PULSE_WIDTH_Y_BITS = intf.PULSE_WIDTH_BITS + intf.PULSE_NUM_X_BITS - 1 - 1;

	StepperCtrl_IF #(
		.PULSE_NUM_BITS(intf.PULSE_NUM_X_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_X_BITS)
	) _intf_x ();

	StepperCtrl_IF #(
		.PULSE_NUM_BITS(intf.PULSE_NUM_Y_BITS),
		.PULSE_WIDTH_BITS(PULSE_WIDTH_Y_BITS)
	) _intf_y ();

	StepperCtrlXY_InnerConnect _inner_conn (
		.intf_xy(intf),
		.intf_x(_intf_x.master),
		.intf_y(_intf_y.master)
	);

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

endmodule : StepperCtrlXY
