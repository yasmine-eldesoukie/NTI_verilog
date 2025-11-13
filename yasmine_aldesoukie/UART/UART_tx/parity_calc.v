module parity_calc (
input wire [7:0] p_data,
input wire data_valid, par_en, par_typ,
output reg par_bit
	);

always @(*) begin
	if (data_valid & par_en & par_typ) begin //odd parity
		par_bit= ~^p_data;
	end
	else if (data_valid & par_en & !par_typ) begin //even parity
		par_bit= ^p_data;
	end
	else begin
		par_bit=1'b0;
	end
end

endmodule