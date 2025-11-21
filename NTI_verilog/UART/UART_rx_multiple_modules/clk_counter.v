module clk_counter #(parameter CLKS_PER_BIT=5208)(
	input wire clk, rst, soft_rst,
	input wire en,
	output reg clk_counter_done, 
	output reg [$clog2(CLKS_PER_BIT)-1:0] clk_counter
	);

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        clk_counter<= CLKS_PER_BIT-1;
        clk_counter_done <=1'b0;
    end
    else if (soft_rst) begin
        clk_counter<= CLKS_PER_BIT-1;
        clk_counter_done <=1'b0;
    end
    else if (clk_counter== 'b0) begin
        clk_counter<= CLKS_PER_BIT-1;
        clk_counter_done<= 1'b1;
    end
    else if (en) begin
        clk_counter<= clk_counter -1;
        clk_counter_done<= 1'b0;
    end
 end
endmodule