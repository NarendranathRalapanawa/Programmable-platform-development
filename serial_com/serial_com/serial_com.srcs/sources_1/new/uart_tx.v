`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 08:42:16 AM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input  wire clk,
    input  wire baud_tick,
    output reg  tx = 1
);

    reg [3:0]  bit_index = 0;
    reg [3:0]  byte_index = 0;
    reg [9:0]  shift_reg = 10'b1111111111;

    // ROM message
    reg [7:0] message[0:12];

    initial begin
        message[0]  = "H";
        message[1]  = "e";
        message[2]  = "l";
        message[3]  = "l";
        message[4]  = "o";
        message[5]  = " ";
        message[6]  = "U";
        message[7]  = "A";
        message[8]  = "R";
        message[9]  = "T";
        message[10] = "!";
        message[11] = 10;   // LF
        message[12] = 13;   // CR
    end

    always @(posedge clk) begin
        if (baud_tick) begin

            // Send current bit
            tx <= shift_reg[0];
            shift_reg <= {1'b1, shift_reg[9:1]}; // shift right

            if (bit_index == 0) begin
                // Load next byte with start&stop bits
                shift_reg <= {1'b1, message[byte_index], 1'b0};
            end
            
            // Move to next bit
            if (bit_index == 9) begin
                bit_index <= 0;
                byte_index <= (byte_index == 12) ? 0 : byte_index + 1;
            end else begin
                bit_index <= bit_index + 1;
            end

        end
    end

endmodule