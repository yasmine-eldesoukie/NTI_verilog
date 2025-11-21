module shift_register (
	input wire clk, rst, soft_rst,
	input wire en,
	input wire rx_data_in,
	output reg [7:0] rx_data_out
	);

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        rx_data_out <='b0;
    end
    else if (soft_rst) begin
        rx_data_out <='b0;
    end
    else if (en) begin 
        rx_data_out <= {rx_data_in,rx_data_out[7:1]};
    end
 end

 endmodule