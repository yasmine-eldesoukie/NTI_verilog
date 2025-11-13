`timescale 1ns/1ps
module UART_TX_REG_FILE_tb #(parameter PERIOD=5);
    //signal declaration
    //inputs
    reg clk, rst;
    reg wr_en_tb, rd_en_tb;
    reg [1:0] wr_addr_tb, rd_addr_tb;
    reg [7:0] wr_data_tb;
    
    //dut outputs
    wire tx_out_dut;
    wire [7:0] rd_data_dut;
 
    //expected outputs
    reg tx_out_expec;
    wire [7:0] rd_data_expec;

    reg busy_expec, done_expec;
    
    //internal signals
    reg [9:0] tx_out_reg;
    reg [7:0] rd_data_reg;

    //instantiation
    UART_TX_REG_FILE_TOP dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en_tb),
        .rd_en(rd_en_tb),
        .wr_addr(wr_addr_tb),
        .rd_addr(rd_addr_tb),
        .wr_data(wr_data_tb),
        .rd_data(rd_data_dut),
        .tx_out(tx_out_dut),
    );

    //clk generation
    always #(PERIOD/2) clk=~clk;

    //stimulus generation in case of a parity bit
    integer i,j;
    initial begin
        $dumpfile("UART_TX.vcd");
        $dumpvars;

        clk=1'b0;

    ///////// Test case 1: Reset dominance /////////
        reset_dominance;

    //////// Test case 2: microcontroller writing ///////
        check_micro_write;
    ///////// Test case 3: Normal functionality /////////
        for (i=0 ; i<400 ; i=i+1) begin
            p_data_tb=$random;
            data_valid_tb=1'b1;
            //generating expected output
            tx_out_reg={1'b1             ,p_data_tb,1'b0};
            

            for (j=0; j<10 ; j=j+1 ) begin
                tx_out_expec=tx_out_reg[j];
                repeat (5208) @(negedge clk);
                if (tx_out_dut != tx_out_expec) begin
                    $display("ERROR IN tx_out,1");
                    $stop;
                end
                @(negedge clk);
                data_valid_tb=1'b0;
            end
            
        end

        ////////////// reset on ////////////////
        rst=1'b0;
        repeat (20) @(negedge clk);
        rst=1'b1;
        ////////////// reset off ////////////////


        @(negedge clk);
        $stop;

    end
    endmodule

    task reset_dominance;
        rst=1'b0;

        tx_out_expec= 'b1;
        rd_data_expec ='b0;
        repeat (20) @(negedge clk);

        for (i=0; i<50 ; i=i+1) begin
            wr_en_tb= $random;
            rd_en_tb= $random;
            wr_addr_tb= $random;
            rd_addr_tb= $random;
            wr_data_tb= $random;
            @(negedge clk);
            check_tx_out_dut;
            check_rd_data_dut;
        end
    endtask

    task check_micro_write;
        begin
            wr_en_tb = 1'b0;
            tx_out_expec= 'b1;
            rd_data_expec ='b0;
            for (i=0; i<2; i=i+1) begin
                wr_addr_tb= i;
                for (j=0; j<256; j=j+1) begin
                    wr_data =j;
                    @(negedge clk);
                    check_tx_out_dut;
                    check_rd_data_dut;
                end
            end 

            //test uart_tx_en dominance
            wr_en_tb = 1'b1;
            wr_addr_tb= 1'b0;
            wr_data_tb= 8'h00;

            tx_out_expec= 'b1;
            rd_data_expec ='b0;

            check_tx_out_dut;
            check_rd_data_dut;

            //test uart_tx_en =1 and that the wr-data is loaded in the UART p_data port
            wr_en_tb = 1'b1;
            wr_addr_tb= 1'b0;
            wr_data_tb= 8'h01;
            @(negedge clk); 

            wr_en_tb = 1'b1;
            wr_addr_tb= 1'b1;

            for (j=0; j<256; j=j+1) begin
                wr_data =j;
                @(negedge clk);
                check_tx_out_dut;
                check_rd_data_dut;
            end
            

        end 
    endtask

//////////////// check tasks ////////////////
    task check_tx_out_dut;
        begin
            if (tx_out_dut != tx_out_expec) begin
                $display("ERROR IN tx_out");
                $stop;
            end
        end
    endtask

    task check_rd_data_dut;
        begin
            if (rd_data_dut != rd_data_expec) begin
                $display("ERROR IN rd_data");
                $stop;
            end
        end
    endtask

    task check_wr_data_p_data;
        begin
            if (wr_data_tb != dut.uart_tx.p_data) begin
                $display("ERROR IN taking p_data in uart");
                $stop;
            end
        end
    endtask

    

//eb2y domehom f task wa7da

