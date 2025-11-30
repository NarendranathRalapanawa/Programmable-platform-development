`timescale 1ns/1ps

module top_tb;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // Shared UART wires
    wire uart_fpga_rx;  // goes into FPGA (PC -> FPGA)
    wire uart_fpga_tx;  // comes from FPGA (FPGA -> PC)

    // Tie to DUT ports
    top dut (
        .CLK100MHZ   (clk),
        .btn0        (rst),
        .uart_txd_in (uart_fpga_rx),
        .uart_rxd_out(uart_fpga_tx)
    );

    // Clock: 100 MHz
    always #5 clk = ~clk;  // 10 ns period

    // "PC-side" UART TX to send bytes into FPGA
    reg        pc_tx_start = 0;
    reg  [7:0] pc_tx_data  = 8'd0;
    wire       pc_tx_busy;

    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD    (115200)
    ) pc_to_fpga_tx (
        .clk   (clk),
        .rst   (rst),
        .start (pc_tx_start),
        .data_in(pc_tx_data),
        .tx    (uart_fpga_rx),
        .busy  (pc_tx_busy)
    );

    // "PC-side" UART RX to decode what FPGA sends back
    wire       pc_rx_valid;
    wire [7:0] pc_rx_data;

    uart_rx #(
        .CLK_FREQ(100_000_000),
        .BAUD    (115200)
    ) fpga_to_pc_rx (
        .clk       (clk),
        .rst       (rst),
        .rx        (uart_fpga_tx),
        .data_valid(pc_rx_valid),
        .data_out  (pc_rx_data)
    );

    // Task to send one byte via pc_to_fpga_tx
    task send_byte(input [7:0] b);
    begin
        // wait until TX is idle
        @(posedge clk);
        while (pc_tx_busy) @(posedge clk);

        pc_tx_data  <= b;
        pc_tx_start <= 1'b1;
        @(posedge clk);
        pc_tx_start <= 1'b0;
    end
    endtask

    // Monitor everything that comes back from FPGA
    always @(posedge clk) begin
        if (pc_rx_valid) begin
            $display("[%0t ns] FPGA UART RX'd -> 0x%02x", $time, pc_rx_data);
        end
    end

    initial begin
        // Initial reset
        rst = 1;
        repeat(20) @(posedge clk);  // 200 ns reset
        rst = 0;
        repeat(1000) @(posedge clk); // wait a bit after reset

        // Now send the same packet as Python:
        // 0x55, 0x00, 0x00, 0x00, 0x00
        $display("[%0t ns] Sending packet 55 00 00 00 00", $time);
        send_byte(8'h55);
        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h00);

        // Wait some time for FPGA to process and respond
        repeat(200_000) @(posedge clk); // 200k cycles ≈ 2 ms

        $display("[%0t ns] Simulation finished", $time);
        $finish;
    end

endmodule
