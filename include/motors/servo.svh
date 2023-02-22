`ifndef __SERVO_SVH__
`define __SERVO_SVH__

`include "common/common.svh"

`ifdef SIM_DEBUG

`define SERVO_PWM_BITS (`WORD_BITS)
`define SERVO_PWM_PERIOD (1_000)
`define SERVO_PWM_UP (50)
`define SERVO_PWM_CENTER (75)
`define SERVO_PWM_DOWN (100)

`define SERVO_TIMER_BITS (`WORD_BITS)
`define SERVO_TIMER_COUNT (5_000)

`else // SIM_DEBUG

`define SERVO_PWM_BITS (`DWORD_BITS)
`define SERVO_PWM_PERIOD (500_000) // 20ms (with 40ns clk)
`define SERVO_PWM_UP (25_000) // 1ms (with 40ns clk)
`define SERVO_PWM_CENTER (35_550) // 1.422ms (with 40ns clk) - empirically measured on servo
`define SERVO_PWM_DOWN (50_000) // 2ms (with 40ns clk)

`define SERVO_TIMER_BITS (`DWORD_BITS)
`define SERVO_TIMER_COUNT (150_000_000) // 6s, 300 pwm periods (40ns clock)

`endif // SIM_DEBUG

`endif // __SERVO_SVH__
