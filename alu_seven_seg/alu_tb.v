module alu_tb ();
  parameter WIDTH=4;
  reg [WIDTH-1:0] a_tb, b_tb;
  reg [1:0] op_code_tb;
  wire status_dut;
  wire [WIDTH-1:0] result_dut;
  reg [WIDTH-1:0] result_expec;
  reg status_expec;
  
  alu #(.WIDTH(4)) dut (
  .a(a_tb),
  .b(b_tb),
  .op_code(op_code_tb),
  .status(status_dut),
  .result(result_dut)
  );
  

  task self_check;
    begin
      if (result_expec!=result_dut) begin
        $display("result_dut=%b, result_expec=%b, time=%t", result_dut, result_expec, $time);
        $stop;
      end
      else if (status_expec!=status_dut) begin
        $display("status_dut=%b, status_expec=%b, time=%t", status_dut, status_expec, $time);
        $stop;
      end
    end
  endtask

  integer i,j,k;
  initial begin
    for (i=0; i<4; i=i+1) begin
      op_code_tb=i;
      for (j=0; j<16; j=j+1) begin
        a_tb=j;
        for (k=0; k<16; k=k+1) begin
          b_tb=k;

          case (op_code_tb) 
            'd0: result_expec= j+k;
            'd1: result_expec= j-k;
            'd2: result_expec= j&k;
            'd3: result_expec= j^k;
          endcase
          status_expec= ((op_code_tb=='b01) && (~|result_expec));
          #5;
          self_check();
          $display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);
        end
      end
    end
    $stop;
  /*
    op_code_tb= 'b00;
	a_tb= 'd6;
	b_tb= 'd10;
  result_expec= 'b0;
  status_expec= 'b0;
	#10; 
  self_check();
  $display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);
	
	op_code_tb= 'b01;
	a_tb= 'd10;
	b_tb= 'd3;
  result_expec= 'd7;
  status_expec= 'b0;
	#10;
  self_check();
  
	$display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);

	op_code_tb= 'b10;
	a_tb= 'b0100;
	b_tb= 'b1101;
  result_expec= 'b0100;
  status_expec= 'b0;
	#10;
  self_check();
	$display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);

	op_code_tb= 'b11;
	a_tb= 'b0100;
	b_tb= 'b1101;
  result_expec= 'b1001;
  status_expec= 'b0;
	#10;
  self_check();
  $display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);

  op_code_tb= 'b00;
	a_tb= 'd1;
	b_tb= 'd2;
  result_expec= 'd4;
  status_expec= 'b0;
	#10;
  self_check();
  $display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);

  op_code_tb= 'b01;
	a_tb= 'd1;
	b_tb= 'd1;
  result_expec= 'd0;
  status_expec= 'b0;
	#10;
  self_check();
  $display("result_dut=%d, status_dut=%b, time=%t", result_dut, status_dut, $time);
  
	$stop;
  */
	  
  end
  
  /*initial begin
  $monitor ("op_code_tb=%b,a_tb=%b, b_tb=%b,status=%b,result=%b", op_code_tb, a_tb, b_tb, status_dut, result_dut);
  end
  */
  
endmodule