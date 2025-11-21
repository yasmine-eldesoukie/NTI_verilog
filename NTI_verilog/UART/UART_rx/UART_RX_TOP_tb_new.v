`timescale 1ns/1ps
module UART_RX_TOP_tb_new #(parameter 
    PAR=2'b00,
    STP=2'b01,
    OUT=2'b10
);
//signal declaration
reg clk, rst, rx_in_tb ,par_en_tb , par_typ_tb;
reg [4:0] prescale_tb;
wire [7:0] p_data_dut;
wire data_valid_dut;

reg strt_glitch_expec, par_err_expec, stp_err_expec,data_valid_expec;

reg [2:0] x;
reg [1:0] type;
reg [7:0] data_reg;
reg [9:0] frame;
reg parity_bit;

//instantiation
UART_RX_TOP dut (
    .clk(clk), 
    .rst(rst), 
    .rx_in(rx_in_tb),
    .par_en(par_en_tb),
    .par_typ(par_typ_tb),
    .prescale(prescale_tb),
    .p_data(p_data_dut),
    .data_valid(data_valid_dut)
    );

//clk generation
initial begin
    clk=1'b0;
    forever #(5/2) clk=~clk;
end

//stimulus generation
integer i,j;
initial begin
    rst=1'b0;
    repeat (20) @(negedge clk);

 ////////////////////////////////// RESET DOMINANCE CHECK //////////////////////////////////

    //RX is async; it's triggered with rx_in = 0 
    //rx_in = 0 with reset on
    rx_in_tb=1'b0;
    repeat (5) @(negedge clk);
 
 ////////////////////////////////// rx_in DOMINANCE CHECK //////////////////////////////////

    //test that as long as rx_in != 0 , RX is off
    //rx_in = 1 again with reset off
    rx_in_tb=1'b1;
    rst=1'b1;
    for (i=7; i<32; i=i*2+1) begin
        prescale_tb=i; 
        for (j=0; j<4; j=j+1) begin
            {par_en_tb,par_typ_tb}=j;
            repeat (prescale_tb+1) @(negedge clk);
        end   
    end

    
 ////////////////////////////////// START CHECK //////////////////////////////////
    /*
    rx uses a faster clk to sample rx_in data coming from a slower block, if rx_in holds a value for most of sampling points, this value will be the sampled_bit value.
    so to make a glitch, let rx_in=0 for one sampling point then 1 for the rest 
    note the 200MHz clk could 8 or 16 or 32 faster than the tx clk, this is controlled in the testbench


    --> This part lets rx_in be 0 for 1 clk to start RX block but then sets rx_in to 1 for the rest of the clks so that data_sampling block samples a 1 
    start_check block is to detect that this is a glitch 
    
    --> expected: strt_glitch signal 1 at edge 7 of bit #0
    */ 

    for (i=7; i<32; i=i*2+1) begin
        prescale_tb=i; 
        rx_in_tb=1'b0;
        @(negedge clk);  
        rx_in_tb=1'b1;
        repeat (prescale_tb) @(negedge clk);
        strt_glitch_expec=1'b1; 
        if (dut.strt_glitch!=strt_glitch_expec) begin
            $display("start check faild at %d", i);
            $stop;
        end
        @(negedge clk);
        strt_glitch_expec=1'b0;
    end

    $display("start check succeeded");
    
    
    for (i=0; i<3; i=i+1) begin
        type=i;
        if (type==0) begin
            par_en_tb=1'b1;
            for(j=0; j<2; j=j+1) begin
                par_typ_tb=j;
                general_check();
            end
            $display("parity check succeeded");   
        end
        else begin 
            for (j=0; j<4; j=j+1) begin
                {par_en_tb,par_typ_tb}=j;
                general_check();
            end
            if (type==1)
                $display("stop check succeeded");
            else 
                $display("out check succeeded");
        end
    end
    
    @(negedge clk);
    $stop;
end

// ------------------------------ // GENERAL CHECK TASK // ------------------------------ //
task general_check; 
         integer a,b,c;
         begin
            for (a=7; a<32; a=a*2+1) begin
                prescale_tb=a; 
            
                for (b=0; b<256; b=b+1) begin
                    rx_in_tb=1'b1;

                 //x determines when the next frame starts
                    x=$random;
                    repeat (x) @(negedge clk);
                    rx_in_tb=1'b0;
                    repeat (prescale_tb+2) @(negedge clk);
                    
                 //all different combinations of 8-bit data
                    data_reg=b;
                    parity_bit=(par_typ_tb)? (~^data_reg): (^data_reg);

                 //constructing the frame

 ////////////////////////////////// PARITY CHECK //////////////////////////////////
 
                    // ---> This part is to set a correct start bit, some data and a wrong parity bit to check the parity_check flow

                    // ---> excpected to find par_err 1 at egde 7 of bit #9

                    if (type==PAR) begin
                        frame={1'b1,~parity_bit,data_reg}; //last bit is dummy
                    end
 ////////////////////////////////// STOP CHECK //////////////////////////////////

                    // --> This part is to set a correct start bit, data, parity bit if par_en on and then a wrong stop bit to check the stop_check flow 

                    // --> excpected to find stp_err 1 at edge 7 of bit #9 if no parity/ bit #10 with parity

                    else if (type==STP & par_en_tb) begin
                        frame={1'b0,parity_bit,data_reg}; 
                    end
                    else if (type==STP) begin
                        frame={1'b1,1'b0,data_reg}; //last bit is duumy
                    end
 ////////////////////////////////// OUT CHECK //////////////////////////////////

                    // --> This part is to set a correct frame to check the out flow "data_valid signal" and p_data 

                    // --> excpected to find data_valid 1 at edge 0 "after the last bit" and p_data = the input data

                    else if (type==OUT & par_en_tb)begin
                        frame={1'b1,parity_bit,data_reg}; 
                    end
                    else begin
                        frame={1'b1,1'b1,data_reg}; //last bit is dummy 
                    end
 //////////////////////////////////////////////////////////////////////////////

                 //assign each bit olf the frame to rx_in for a number of (prescale +1) clks
                    for (c=0; c<(9+((type!=0) & par_en_tb)); c=c+1) begin
                        rx_in_tb=frame[c];
                        repeat (prescale_tb) @(negedge clk); 
                        if (c!=8) 
                           @(negedge clk);                     
                    end

                 //checking based on frame  
                    if (type==PAR) begin
                        par_err_expec=1'b1;
                        if (dut.par_err!= par_err_expec) begin
                            $display("parity check faild at%d, parity:%b",b,par_en_tb);
                            $stop;
                        end
                        @(negedge clk);
                        par_err_expec=1'b0;
                    end
                    else if (type==STP) begin
                        stp_err_expec=1'b1;
                        if (dut.stp_err!= stp_err_expec) begin
                            $display("stop check faild at%d, parity:%b",b,par_en_tb);
                            $stop;
                        end
                        
                        @(negedge clk);
                        stp_err_expec=1'b0;  
                    end
                    else begin
                        @(negedge clk);
                        data_valid_expec=1'b1;
                        if ((data_valid_dut != data_valid_expec) | p_data_dut!=data_reg) begin
                           $display("out check faild at%d, parity:%b",b,par_en_tb);
                           $stop;
                        end
                        
                        @(negedge clk);
                        data_valid_expec=1'b0;
                    end //else
                end //for b
            end //for a
        end //begin
endtask

endmodule


