module alu_top (
 input wire [3:0] a,b,
 input wire [1:0] op_code,
 output wire [6:0] result,
 output wire status
 );
 
 wire [3:0] alu_res ;
 
alu alu (
  .a(a),
  .b(b),
  .op_code(op_code),
  .status(status),
  .result(alu_res)
  );
  
seven_seg seven_seg (
   .in(alu_res),
   .out(result)
   );
   
endmodule