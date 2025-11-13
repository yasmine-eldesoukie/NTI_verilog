module serializer #(parameter 
	CLK_PER_BIT= 5208, //50 mega divided 9600 Hz //since the FPGA clk is 50 Mhz and UART is 9600
	CLK_COUNTER_WIDTH= $clog2(CLK_PER_BIT)
)
(
input wire [7:0] p_data,
input wire ser_en, clk, rst, 
output reg out_data, ser_done
);
reg [3:0] counter;
reg [CLK_COUNTER_WIDTH-1:0] clk_counter;

/*always @(posedge clk or negedge rst) begin
   if (!rst) begin
	   counter<=4'b0000;
       ser_done<=1'b0;
   end
   else if (ser_en) begin
       if (counter==8)
          ser_done<=1'b1;
       else 
          ser_done<=1'b0;
       counter <= counter +1'b1;  
   end 
end

always @(posedge clk or negedge rst) begin
if (!rst)
     out_data<=1'b1;
else if (ser_en & !ser_done) begin
     out_data <= p_data [counter];
     $display("data %d:", counter);
     end
else begin
     out_data<=1'b1;
     $display("one");
     end
end
*/

always @(negedge clk or negedge rst) begin
	if (!rst) begin
		clk_counter<='b0;
	end
	else if (clk_counter==CLK_PER_BIT) begin
		clk_counter<= 'b0;
	end
	else if (ser_en) begin
		clk_counter <= clk_counter+1;
	end
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
	    out_data<=1'b1;
        counter<=4'b0000;
        ser_done<=1'b0;
    end
    else if (ser_en & !ser_done & (clk_counter!=CLK_PER_BIT)) begin
        out_data <= p_data [counter];
    end
	else if (clk_counter==CLK_PER_BIT) begin 
	    counter  <= counter+1'b1;
        if (counter==7) 
           ser_done<=1'b1;
        else 
           ser_done<=1'b0;
	end
    else begin
     out_data<=1'b1;
     counter<=4'b0000;
     ser_done<=1'b0;
    end
end

endmodule

