module UART_rx_top #(parameter CLKS_PER_BIT=5208)(
	input wire clk, rst, soft_rst,
 	input wire rx_data_in,
 	output wire rx_busy, rx_done, error,
 	output wire [7:0] rx_data_out
);

wire [$clog2(CLKS_PER_BIT)-1:0] clk_counter;
wire [2:0] bit_counter;
wire clk_counter_done;
wire clk_counter_en, bit_counter_en, shift_register_en;

clk_counter #(CLKS_PER_BIT) clk_count(
	.clk(clk),
	.rst(rst),
	.soft_rst(soft_rst),
    .en(clk_counter_en),
    .clk_counter(clk_counter),
    .clk_counter_done(clk_counter_done)
    );

bit_counter bit_count(
	.clk(clk),
	.rst(rst),
	.soft_rst(soft_rst),
    .en(bit_counter_en),
    .clk_counter_done(clk_counter_done),
    .bit_counter(bit_counter)
    );

shift_register shift_register (
	.clk(clk),
	.rst(rst),
	.soft_rst(soft_rst),
    .en(shift_register_en),
    .rx_data_in(rx_data_in),
    .rx_data_out(rx_data_out)
    );

FSM #(CLKS_PER_BIT) FSM (
	.clk(clk),
	.rst(rst),
	.soft_rst(soft_rst),
	.rx_data_in(rx_data_in),
	.clk_counter(clk_counter),
	.bit_counter(bit_counter),
	.clk_counter_done(clk_counter_done),
	.clk_counter_en(clk_counter_en),
	.bit_counter_en(bit_counter_en),
	.shift_register_en(shift_register_en),
	.rx_busy(rx_busy), 
	.rx_done(rx_done), 
	.error(error)
	);

endmodule
