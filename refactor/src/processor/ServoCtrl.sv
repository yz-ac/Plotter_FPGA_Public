`include "common/common.svh"
`include "processor/processor.svh"

import Servo_P::ServoPos_t;
import Servo_P::ServoMov_t;

module ServoCtrl (
	input logic clk,
	input logic reset,
	input logic clk_en,
	ServoCtrl_IF intf,

	output logic out
);

	Servo_P::ServoMov_t _mov;
	wire [`SERVO_PWM_BITS-1:0] _on_time;
	wire _working;
	wire _pwm_en;
	wire _pulse_done;

	ServoCtrl_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(intf.trigger),
		.pos(intf.pos),
		.pulse_done(_pulse_done),
		.mov(_mov),
		.working(_working)
	);

	ServoMovToPwm _mov_to_pwm (
		.mov(_mov),
		.on_time(_on_time)
	);

	PulseGen #(
		.PULSE_NUM_BITS(1),
		.PULSE_WIDTH_BITS(`SERVO_MOV_BITS)
	) _pulse_gen (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.pulse_num(1),
		.pulse_width(`SERVO_MOV_TIME),
		.trigger(intf.trigger),
		.out(_pwm_en),
		.done(_pulse_done)
	);

	Pwm #(
		.PERIOD_BITS(`SERVO_PWM_BITS)
	) _pwm (
		.clk(clk),
		.reset(reset),
		.clk_en(_pwm_en),
		.period(`SERVO_PWM_PERIOD),
		.on_time(_on_time),
		.out(out)
	);

	assign intf.done = !_working;

endmodule : ServoCtrl
