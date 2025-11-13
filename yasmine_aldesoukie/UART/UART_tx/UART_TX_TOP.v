module UART_TX_TOP (
   input wire [7:0] p_data,
   input wire data_valid, clk, rst,
   //input wire par_en, par_typ,
   output wire tx_out, busy, uart_tx_done
);

wire ser_done, ser_en, ser_data, uart_tx_data; 
//wire par_bit;
wire [1:0] mux_sel;

UART_TX_FSM FSM (
	.clk(clk),
	.rst(rst),
	.data_valid(data_valid),
	.ser_done(ser_done),
	//.par_en(par_en),
	.ser_en(ser_en),
	.busy(busy),
	.uart_tx_done(uart_tx_done),
	.mux_sel(mux_sel)
);

/*parity_calc par_calc (
	.p_data(p_data),
	.data_valid(data_valid),
	.par_en(par_en),
	.par_typ(par_typ),
	.par_bit(par_bit)
); 
*/
mux_4_to_1 mux (
	.sel(mux_sel),
	.s2(ser_data),
	//.s3(par_bit),
	.mux_out(tx_out)
);

serializer serializer_unit (
	.p_data(p_data),
	.ser_en(ser_en),
	.clk(clk),
	.rst(rst),
	.out_data(ser_data),
	.ser_done(ser_done)
);

endmodule