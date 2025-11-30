`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 08:40:17 AM
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_top(
    input  wire clk,     // 100 MHz clock from Nexys A7
    output wire tx       // UART TX output to PC
);

    wire baud_tick;

    // Baud rate generator: 100 MHz -> 115200 baud
    baud_gen baud_gen_inst(
        .clk(clk),
        .baud_tick(baud_tick)
    );

    // UART transmitter
    uart_tx uart_tx_inst(
        .clk(clk),
        .baud_tick(baud_tick),
        .tx(tx)
    );

endmodule