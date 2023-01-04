`include "processor/processor.svh"

/**
* Multiplies pulse number to stepper motors to fit mechanics precision.
*
* :iface intf_in: Interface from handlers' side.
* :iface intf_out: Interface to motors side (multiplied).
*/
module PulseNumMultiplier (
	MotorsCtrl_IF intf_in,
	MotorsCtrl_IF intf_out
);

	localparam IN_X_BITS = intf_in.PULSE_NUM_X_BITS;
	localparam IN_Y_BITS = intf_in.PULSE_NUM_Y_BITS;
	localparam OUT_X_BITS = intf_out.PULSE_NUM_X_BITS;
	localparam OUT_Y_BITS = intf_out.PULSE_NUM_Y_BITS;

	wire [OUT_X_BITS-1:0] _extended_pulse_num_x;
	wire [OUT_Y_BITS-1:0] _extended_pulse_num_y;

	assign _extended_pulse_num_x = {{OUT_X_BITS-IN_X_BITS{intf_in.pulse_num_x[IN_X_BITS-1]}}, intf_in.pulse_num_x[IN_X_BITS-1:0]};
	assign _extended_pulse_num_y = {{OUT_Y_BITS-IN_Y_BITS{intf_in.pulse_num_y[IN_Y_BITS-1]}}, intf_in.pulse_num_y[IN_Y_BITS-1:0]};

	assign intf_out.pulse_num_x = _extended_pulse_num_x * `STEPPER_PULSE_NUM_X_FACTOR;
	assign intf_out.pulse_num_y = _extended_pulse_num_y * `STEPPER_PULSE_NUM_Y_FACTOR;
	assign intf_out.servo_pos = intf_in.servo_pos;
	assign intf_out.trigger = intf_in.trigger;
	assign intf_in.done = intf_out.done;
	assign intf_in.rdy = intf_out.rdy;

endmodule : PulseNumMultiplier
