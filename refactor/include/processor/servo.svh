`ifndef __SERVO_SVH__
`define __SERVO_SVH__

`include "common/common.svh"

`ifdef SIM_DEBUG

`define SERVO_PWM_BITS (`WORD_BITS)
`define SERVO_PWM_PERIOD (1_000) // 20us (with 20ns clk)
`define SERVO_PWM_UP (50) // 1us (with 20ns clk)
`define SERVO_PWM_CENTER (75) // 1.5us (with 20ns clk)
`define SERVO_PWM_DOWN (100) // 2us (with 20ns clk)

`define SERVO_MOV_BITS (`WORD_BITS)
`define SERVO_MOV_TIME (5_000) // 100us (with 20ns clk)

`else // SIM_DEBUG

`define SERVO_PWM_BITS (`DWORD_BITS)
`define SERVO_PWM_PERIOD (1_000_000) // 20ms (with 20ns clk)
`define SERVO_PWM_UP (50_000) // 1ms (with 20ns clk)
`define SERVO_PWM_CENTER (75_000) // 1.5ms (with 20ns clk)
`define SERVO_PWM_DOWN (100_000) // 2ms (with 20ns clk)

`define SERVO_MOV_BITS (`DWORD_BITS)
`define SERVO_MOV_TIME (5_000_000) // 100ms (with 20ns clk)

`endif // SIM_DEBUG

`endif // __SERVO_SVH__
