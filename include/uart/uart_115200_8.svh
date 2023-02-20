`ifndef __UART_115200_8_SVH__
`define __UART_115200_8_SVH__

`define UART_BAUD_RATE (115200)
`define UART_CLKS_PER_BIT (217) // round(25MHz / 115200)
`define UART_COUNTER_BITS (8) // clog2(clks_per_bit)
`define UART_DATA_SIZE (8)
`define UART_DATA_SIZE_BITS (3)

`endif // __UART_115200_8_SVH__
