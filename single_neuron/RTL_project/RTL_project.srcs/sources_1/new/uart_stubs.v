`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 01:03:16 AM
// Design Name: 
// Module Name: uart_stubs
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


// -------------------------------------------------
// Stub UART RX - synthesis only, no real receive
// -------------------------------------------------
// Simple UART RX: 8N1, single-sample per bit
module uart_rx #
(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)
(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg        data_valid,
    output reg [7:0]  data_out
);

    localparam integer DIV = CLK_FREQ / BAUD;

    localparam [1:0]
        S_IDLE  = 2'd0,
        S_START = 2'd1,
        S_DATA  = 2'd2,
        S_STOP  = 2'd3;

    reg [1:0]  state = S_IDLE;
    reg [15:0] cnt   = 0;
    reg [2:0]  bit_idx = 0;
    reg [7:0]  shreg   = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= S_IDLE;
            cnt        <= 0;
            bit_idx    <= 0;
            data_valid <= 1'b0;
        end else begin
            data_valid <= 1'b0; // pulse

            case (state)
                S_IDLE: begin
                    if (!rx) begin          // start bit (low)
                        state <= S_START;
                        cnt   <= 0;
                    end
                end

                S_START: begin
                    if (cnt == (DIV/2)) begin
                        // sample in middle of start bit
                        if (!rx) begin
                            cnt     <= 0;
                            bit_idx <= 0;
                            state   <= S_DATA;
                        end else begin
                            state <= S_IDLE; // false start
                        end
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                S_DATA: begin
                    if (cnt == DIV-1) begin
                        cnt <= 0;
                        shreg[bit_idx] <= rx; // LSB first
                        if (bit_idx == 3'd7)
                            state <= S_STOP;
                        else
                            bit_idx <= bit_idx + 1;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                S_STOP: begin
                    if (cnt == DIV-1) begin
                        state      <= S_IDLE;
                        data_out   <= shreg;
                        data_valid <= 1'b1;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule
// Simple UART TX: 8N1
module uart_tx #
(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)
(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        busy
);

    localparam integer DIV = CLK_FREQ / BAUD;

    localparam [1:0]
        S_IDLE  = 2'd0,
        S_START = 2'd1,
        S_DATA  = 2'd2,
        S_STOP  = 2'd3;

    reg [1:0]  state = S_IDLE;
    reg [15:0] cnt   = 0;
    reg [2:0]  bit_idx = 0;
    reg [7:0]  shreg   = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= S_IDLE;
            cnt     <= 0;
            bit_idx <= 0;
            shreg   <= 0;
            tx      <= 1'b1;   // idle high
            busy    <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        shreg   <= data_in;
                        state   <= S_START;
                        cnt     <= 0;
                        busy    <= 1'b1;
                    end
                end

                S_START: begin
                    tx <= 1'b0; // start bit
                    if (cnt == DIV-1) begin
                        cnt     <= 0;
                        bit_idx <= 0;
                        state   <= S_DATA;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                S_DATA: begin
                    tx <= shreg[bit_idx];
                    if (cnt == DIV-1) begin
                        cnt <= 0;
                        if (bit_idx == 3'd7)
                            state <= S_STOP;
                        else
                            bit_idx <= bit_idx + 1;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                S_STOP: begin
                    tx <= 1'b1; // stop bit
                    if (cnt == DIV-1) begin
                        state <= S_IDLE;
                        cnt   <= 0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule

