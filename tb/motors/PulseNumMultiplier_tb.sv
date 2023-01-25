`include "tb/simulation.svh"
`include "common/common.svh"
`include "motors/motors.svh"

import Servo_PKG::SERVO_POS_UP;

`define LOG() \
		`FWRITE(("time: %t, in: (%d, %d), out: (%d, %d)", $time, pulse_num_x_in, pulse_num_y_in, pulse_num_x_out, pulse_num_y_out))

module PulseNumMultiplier_tb;
	int fd;

	localparam IN_X_BITS = `POS_X_BITS;
	localparam IN_Y_BITS = `POS_Y_BITS;
	localparam OUT_X_BITS = `STEPPER_PULSE_NUM_X_BITS;
	localparam OUT_Y_BITS = `STEPPER_PULSE_NUM_Y_BITS;

	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(IN_X_BITS),
		.PULSE_NUM_Y_BITS(IN_Y_BITS)
	) intf_in ();

	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(OUT_X_BITS),
		.PULSE_NUM_Y_BITS(OUT_Y_BITS)
	) intf_out ();

	reg [IN_X_BITS-1:0] pulse_num_x_in;
	reg [IN_Y_BITS-1:0] pulse_num_y_in;
	wire [OUT_X_BITS-1:0] pulse_num_x_out;
	wire [OUT_Y_BITS-1:0] pulse_num_y_out;

	PulseNumMultiplier UUT (
		.intf_in(intf_in.slave),
		.intf_out(intf_out.master)
	);

	assign intf_in.master.pulse_num_x = pulse_num_x_in;
	assign intf_in.master.pulse_num_y = pulse_num_y_in;
	assign intf_in.master.servo_pos = SERVO_POS_UP;
	assign intf_in.master.trigger = 0;

	assign intf_out.slave.done = 0;
	assign intf_out.slave.rdy = 0;

	assign pulse_num_x_out = intf_out.slave.pulse_num_x;
	assign pulse_num_y_out = intf_out.slave.pulse_num_y;

	initial begin
		`FOPEN("tests/tests/PulseNumMultiplier_tb.txt")

		pulse_num_x_in = 3;
		pulse_num_y_in = 2;
		#(`CLOCK_PERIOD * 2);
		`LOG

		pulse_num_x_in = 4;
		pulse_num_y_in = -5;
		#(`CLOCK_PERIOD * 2);
		`LOG

		pulse_num_x_in = -1;
		pulse_num_y_in = 0;
		#(`CLOCK_PERIOD * 2);
		`LOG

		`FCLOSE
		`STOP
	end // initial

endmodule : PulseNumMultiplier_tb
