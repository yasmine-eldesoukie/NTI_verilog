module alu #(parameter WIDTH=4)(
    input wire [WIDTH-1:0] a, b,
    input wire [1:0] op_code,
    output wire status,
    output reg [WIDTH-1:0] result
);
	parameter [1:0] sum='b00;
	parameter [1:0] sub='b01;
	parameter [1:0] andd='b10;
	parameter [1:0] xorr='b11;

always @(*) begin
    case (op_code) 
     sum: begin
       result= a+b;
     end
     sub: begin
       result= a-b;
     end
     andd: begin
       result= (a&b);
     end
     xorr: begin
       result= (a^b);
     end
    endcase
end

assign status= ((op_code==sub ) && ~( |result));

endmodule