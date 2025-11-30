module top (
    input  wire CLK100MHZ,   // board clock
    input  wire btn0,        // reset button
    input  wire uart_txd_in, // PC -> FPGA
    output wire uart_rxd_out // FPGA -> PC
);
    // Basic clock & reset
    wire clk = CLK100MHZ;
    wire rst = btn0;  // active high; invert if you want active low

    // UART wires
    wire       rx_valid;
    wire [7:0] rx_data;
    wire       tx_busy;
    reg        tx_start;
    reg  [7:0] tx_data;

    // ===== UART modules (you must provide these) =====
    uart_rx u_rx (
        .clk(clk),
        .rst(rst),
        .rx(uart_txd_in),
        .data_valid(rx_valid),
        .data_out(rx_data)
    );

    uart_tx u_tx (
        .clk(clk),
        .rst(rst),
        .start(tx_start),
        .data_in(tx_data),
        .tx(uart_rxd_out),
        .busy(tx_busy)
    );

    // ===== hls4ml core nn_top =====
    reg  [15:0] x0_reg, x1_reg;
    wire [15:0] y_wire;

    nn_top u_nn (
        .ap_clk(clk),
        .ap_rst(rst),
        .x0_V(x0_reg),
        .x1_V(x1_reg),
        .y_V(y_wire)
    );

    // ===== simple UART protocol FSM =====
    reg [3:0]  state;
    reg [15:0] x0_temp, x1_temp;
    reg [3:0]  wait_cnt;

    localparam S_WAIT_HDR = 4'd0;
    localparam S_X0_L     = 4'd1;
    localparam S_X0_H     = 4'd2;
    localparam S_X1_L     = 4'd3;
    localparam S_X1_H     = 4'd4;
    localparam S_WAIT_Y   = 4'd5;
    localparam S_SEND_HDR = 4'd6;
    localparam S_SEND_Y_L = 4'd7;
    localparam S_SEND_Y_H = 4'd8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= S_WAIT_HDR;
            tx_start <= 1'b0;
            x0_reg   <= 16'd0;
            x1_reg   <= 16'd0;
            wait_cnt <= 4'd0;
        end else begin
            tx_start <= 1'b0;

            case (state)
                S_WAIT_HDR: begin
                    if (rx_valid && rx_data == 8'h55)
                        state <= S_X0_L;
                end

                S_X0_L: if (rx_valid) begin
                    x0_temp[7:0] <= rx_data;
                    state <= S_X0_H;
                end

                S_X0_H: if (rx_valid) begin
                    x0_temp[15:8] <= rx_data;
                    state <= S_X1_L;
                end

                S_X1_L: if (rx_valid) begin
                    x1_temp[7:0] <= rx_data;
                    state <= S_X1_H;
                end

                S_X1_H: if (rx_valid) begin
                    x1_temp[15:8] <= rx_data;
                    x0_reg   <= x0_temp;
                    x1_reg   <= x1_temp;
                    wait_cnt <= 4'd0;
                    state    <= S_WAIT_Y;
                end

                S_WAIT_Y: begin
                    wait_cnt <= wait_cnt + 1'b1;
                    if (wait_cnt == 4'd8)
                        state <= S_SEND_HDR;
                end

                S_SEND_HDR: begin
                    if (!tx_busy) begin
                        tx_data  <= 8'hAA;
                        tx_start <= 1'b1;
                        state    <= S_SEND_Y_L;
                    end
                end

                S_SEND_Y_L: begin
                    if (!tx_busy) begin
                        tx_data  <= y_wire[7:0];
                        tx_start <= 1'b1;
                        state    <= S_SEND_Y_H;
                    end
                end

                S_SEND_Y_H: begin
                    if (!tx_busy) begin
                        tx_data  <= y_wire[15:8];
                        tx_start <= 1'b1;
                        state    <= S_WAIT_HDR;
                    end
                end
            endcase
        end
    end

endmodule
