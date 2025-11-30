## Clock 100 MHz
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -name sys_clk -period 10.00 [get_ports { clk }];

## UART TX (FPGA → PC USB-UART)
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports { tx }];