module UART_RX_one_module_tb #(parameter CLKS_PER_BIT= 3)();
reg clk, rst, soft_rst_tb; 
reg rx_data_in_tb;
wire rx_busy_dut, rx_done_dut, error_dut;
wire [7:0] rx_data_out_dut;

//internal signals 
reg [9:0] tx_frame_tb;

//instantiation
UART_RX #(CLKS_PER_BIT) dut (
    .clk(clk),
    .rst(rst),
    .soft_rst(soft_rst_tb),
    .rx_data_in(rx_data_in_tb),
    .rx_busy(rx_busy_dut), 
    .rx_done(rx_done_dut), 
    .error(error_dut),
    .rx_data_out(rx_data_out_dut)
);

//clk generation
initial begin
    clk=1'b0;
    forever #1 clk= ~clk;
end

//stimulus generation
integer i,j;
initial begin
    //test reset dominance
    rst= 1'b0;
    rx_data_in_tb=1'b0;
    repeat (12*CLKS_PER_BIT) begin //wait time is any number > 10 since frame is ten bits , multiplied by CLKS_PER_BIT
        @(negedge clk);
        if (rx_busy_dut != 'b0) begin
            $display("ERROR in rst");
            $stop;
        end
    end

    //test soft reset dominance
    rst= 1'b1;
    soft_rst_tb=1'b1;
    rx_data_in_tb=1'b0;
    repeat (12*CLKS_PER_BIT) begin
        @(negedge clk);
        if (dut.cs!= 'b0) begin
            $display("ERROR in soft_rst signal");
            $stop;
        end
    end

    rst=1'b1;
    soft_rst_tb=1'b0;
    rx_data_in_tb=1'b1;
    repeat (5) @(negedge clk);

    for (i=0; i<256; i=i+1) begin
        tx_frame_tb={1'b1, i[7:0], 1'b0};
        for (j=0; j<10; j=j+1) begin
            repeat (CLKS_PER_BIT)  begin
              @(negedge clk)
              rx_data_in_tb= tx_frame_tb[j];
            end
            if (rx_busy_dut!= 1) begin
                $display("ERROR in busy signal");
                $stop;
            end
        end
        //frame is sent--> check busy and done signals and rx_out
        @(negedge clk);
        if (rx_busy_dut!= 0) begin
                $display("ERROR in busy signal");
                $stop;
            end
        if (rx_done_dut!= 1) begin
            $display("ERROR in done signal");
            $stop;
        end
        if (rx_data_out_dut!= i[7:0]) begin
            $display("ERROR in done signal");
            $stop;
        end
    end

    //test error state
    tx_frame_tb={1'b0, 8'b00110011, 1'b0}; //wrong stop bit
    for (j=0; j<10; j=j+1) begin
        repeat (CLKS_PER_BIT)  begin
          @(negedge clk)
          rx_data_in_tb= tx_frame_tb[j];
        end
    end
    @(negedge clk);
    if (error_dut!= 1) begin
        $display("ERROR in error signal");
        $stop;
    end

    // test that it stays in ERROR state
    repeat (10) @(negedge clk);
    rx_data_in_tb=1'b1;
    @(negedge clk);
    rx_data_in_tb=1'b0;
    repeat (CLKS_PER_BIT*10)  begin
      @(negedge clk)    
      if (error_dut!= 1) begin
        $display("ERROR in error state");
        $stop;
      end
    end

    $stop;
end

endmodule