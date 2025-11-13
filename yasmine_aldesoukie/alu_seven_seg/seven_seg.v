module seven_seg (
input wire [3:0] in,
output reg [6:0] out
);

always @(*) begin
 case (in)
   'd0: out= 'b0000001;
   'd1: out= 'b1001111;
   'd2: out= 'b0010010;
   'd3: out= 'b0000110;
   'd4: out= 'b1001100;
   'd5: out= 'b0100100;
   'd6: out= 'b0100000;
   'd7: out= 'b0001111;
   'd8: out= 'b0000000;
   'd9: out= 'b0000100;
   'd10: out= 'b0001000;
   'd11: out= 'b1100000;
   'd12: out= 'b0110001;
   'd13: out= 'b0110000;
   'd14: out= 'b1000010; // correct it
   'd15: out= 'b0111000;
 endcase 
end
endmodule