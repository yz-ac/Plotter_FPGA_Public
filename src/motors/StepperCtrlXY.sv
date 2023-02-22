/**
* Module for controlling stepper motors in X and Y directions.
*
* :param MULT_X: Multiplier for pulses in the X axis.
* :param MULT_Y: Multiplier for pulses in the Y axis.
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :iface intf: Interface for controlling XY stepper motors.
* :output out_x: Pulses to X motor.
* :output dir_x: Direction of X motor.
* :output n_en_x: Enable signal for X driver (active low) to prevent idle current.
* :output out_y: Pulses to Y motor.
* :output dir_y: Direction of Y motor.
* :output n_en_y: Enable signal for Y driver (active low) to prevent idle current.
*/
module StepperCtrlXY #(
	parameter MULT_X = 1,
	parameter MULT_Y = 1
)
(
	input logic clk,
	input logic reset,
	input logic clk_en,
	StepperCtrlXY_IF intf,
	output logic out_x,
	output logic dir_x,
	output logic n_en_x,
	output logic out_y,
	output logic dir_y,
	output logic n_en_y
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

	StepperCtrl #(
		.MULT(MULT_X)
	) _stepper_ctrl_x (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(_intf_x.slave),
		.out(out_x),
		.dir(dir_x),
		.n_en(n_en_x)
	);

	StepperCtrl #(
		.MULT(MULT_Y)
	) _stepper_ctrl_y (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.intf(_intf_y.slave),
		.out(out_y),
		.dir(dir_y),
		.n_en(n_en_y)
	);

endmodule : StepperCtrlXY
