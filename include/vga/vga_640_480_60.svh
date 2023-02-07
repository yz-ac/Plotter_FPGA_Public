`ifndef __VGA_640_480_60_SVH__
`define __VGA_640_480_60_SVH__

`define VGA_FREQ_DIV (2) // 50MHz main clock => 25MHz pixel clock
`define VGA_FREQ_DIV_BITS (2)

`define VGA_H_ACTIVE (640)
`define VGA_H_FRONT (16)
`define VGA_H_SYNC (96)
`define VGA_H_BACK (48)
`define VGA_H_BITS (10)
`define VGA_HS_POLARITY (1) // Active low

`define VGA_V_ACTIVE (480)
`define VGA_V_FRONT (11)
`define VGA_V_SYNC (2)
`define VGA_V_BACK (31)
`define VGA_V_BITS (10)
`define VGA_VS_POLARITY (1) // Active low

`define VGA_ROWS (`VGA_V_ACTIVE)
`define VGA_COLS (`VGA_H_ACTIVE)

`endif // __VGA_640_480_60_SVH__
