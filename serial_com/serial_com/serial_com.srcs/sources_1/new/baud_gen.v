`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 08:41:18 AM
// Design Name: 
// Module Name: baud_gen
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


module baud_gen(
    input  wire clk,
    output reg  baud_tick = 0
);

    reg [9:0] count = 0;

    always @(posedge clk) begin
        if (count == 867) begin
            baud_tick <= 1;
            count <= 0;
        end else begin
            baud_tick <= 0;
            count <= count + 1;
        end
    end

endmodule