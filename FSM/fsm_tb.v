module fsm_tb();
   reg clk, rst;
   reg a_tb, b_tb;
   wire y0_dut, y1_dut;

   fsm dut (
    .clk(clk), 
    .rst(rst),
    .a(a_tb),
    .b(b_tb),
    .y0(y0_dut),
    .y1(y1_dut)
   ); 

   initial begin
      clk= 1'b0;
      forever #(7/2) clk= ~clk;
   end

   initial begin
      rst= 1'b0;
      a_tb=0;
      b_tb=0;
      repeat (10) @(negedge clk);

      rst= 1'b1;
      //test S0> S0> S1> S1> S0> S2> S0
      a_tb= 0;
      b_tb= 1;
      @(negedge clk); //S0

      a_tb= 1;
      b_tb= 0;
      @(negedge clk); //S1

      a_tb= 0;
      b_tb= 1;
      @(negedge clk); //S1

      a_tb= 1;
      b_tb= 1;
      @(negedge clk); //S0

      a_tb= 1;
      b_tb= 1;
      #1
      a_tb= 0;
      #1
      a_tb= 1;
      @(negedge clk); //S2

      a_tb= 1;
      b_tb= 1;
      @(negedge clk); //s0
      
      repeat (5) @(negedge clk);
      $stop;
   end
endmodule