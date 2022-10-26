`ifndef __SERVO_SVH__
`define __SERVO_SVH__

`define SERVO_CLK_EN_BITS (13)
`define SERVO_CLK_EN (5_000) // 20ns * 5000 * SERVO_PERIOD = 20ms
`define SERVO_PERIOD (200) // 20ms period of servo pwm from datasheet
`define SERVO_DUTY_UP (10) // 1ms uptime for upward position (datasheet)
`define SERVO_DUTY_DOWN (15) // 1.5ms uptime for mid position (datasheet)

typedef enum {
	SERVO_POS_DOWN,
	SERVO_POS_UP
} ServoPosition_t;

`endif // __SERVO_SVH__
