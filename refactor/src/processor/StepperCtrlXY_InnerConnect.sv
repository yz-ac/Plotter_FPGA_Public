/**
* Module to connect XY interface with 2 separate stepper motor interfaces.
*
* :iface intf_xy: Stepper motor XY interface.
* :iface intf_x: Interface of X stepper motor.
* :iface intf_y: Interface of Y stepper motor.
*/
module StepperCtrlXY_InnerConnect (
	StepperCtrlXY_IF intf_xy,
	StepperCtrl_IF intf_x,
	StepperCtrl_IF intf_y
);

	wire [intf_x.PULSE_NUM_BITS-2:0] _abs_pulse_num_x;
	wire [intf_y.PULSE_NUM_BITS-2:0] _abs_pulse_num_y;

	Abs #(
		.NUM_BITS(intf_x.PULSE_NUM_BITS)
	) _abs_x (
		.num(intf_xy.pulse_num_x),
		.out(_abs_pulse_num_x)
	);

	Abs #(
		.NUM_BITS(intf_y.PULSE_NUM_BITS)
	) _abs_y (
		.num(intf_xy.pulse_num_y),
		.out(_abs_pulse_num_y)
	);

	always_comb begin : __mult_pulse_width
		intf_x.pulse_width = intf_xy.pulse_width * _abs_pulse_num_y;
		intf_y.pulse_width = intf_xy.pulse_width * _abs_pulse_num_x;
		if ((~|_abs_pulse_num_x) | (~|_abs_pulse_num_y)) begin
			intf_x.pulse_width = intf_xy.pulse_width;
			intf_y.pulse_width = intf_xy.pulse_width;
		end
	end : __mult_pulse_width // always_comb

	assign intf_x.pulse_num = intf_xy.pulse_num_x;
	assign intf_y.pulse_num = intf_xy.pulse_num_y;
	
	assign intf_x.trigger = intf_xy.trigger;
	assign intf_y.trigger = intf_xy.trigger;

	assign intf_xy.done = (intf_x.done & intf_y.done) ? 1 : 0;
	assign intf_xy.rdy = (intf_x.rdy & intf_y.rdy) ? 1 : 0;

endmodule : StepperCtrlXY_InnerConnect
