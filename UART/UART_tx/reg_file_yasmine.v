module reg_file #(parameter 
    WIDTH= 8,
    DEPTH= 4
)
(   //micrcontroller interface
    input wire clk, rst,
    input wire wr_en, rd_en, 
    input wire wr_addr, rd_addr,
    input wire [7:0] wr_data,
    output reg [7:0] rd_data,
    //uart_tx
    input wire busy, uart_tx_done,
    output wire [7:0] tx_p_data,
    output wire uart_tx_data_valid //enable signal for uart_tx
);

reg [WIDTH-1:0] reg_control, reg_tx_data, reg_rx_data, reg_status;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        reg_control <= 'b0;
        reg_tx_data <= 'b0;
        reg_rx_data <= 'b0;
        reg_status  <= 'b0;
    end
    else begin
        /*if (uart_rx_ready)
            reg_rx_data <= uart_rx_out;
        */
        reg_status <= {{(WIDTH-2){1'b0}}, uart_tx_done, busy};

        if (wr_en) begin 
            case (wr_addr) 
              'b0: begin
               reg_control <= wr_data;
            end
              'b1: begin
               reg_tx_data <= wr_data;
            end
            endcase 
        end
        else if (rd_en) begin
            case (rd_addr) 
            'b0: begin
                rd_data <= reg_rx_data;
            end
            'b1: begin
                rd_data <= reg_status;
            end
            endcase 
        end
    end 
end

assign uart_tx_data_valid= reg_control[0];
assign tx_p_data = reg_tx_data;

endmodule