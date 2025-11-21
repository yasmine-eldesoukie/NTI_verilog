module bit_counter (
	input wire clk, rst, soft_rst,
	input wire en, clk_counter_done,
	output reg [2:0] bit_counter
	);

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        bit_counter<= 'b0;
    end
    else if (soft_rst) begin
        bit_counter<= 'b0;
    end
    else if (en && clk_counter_done) begin
        bit_counter<= bit_counter +1;
    end
 end

 endmodule