module parity_check (
	input wire par_chk_en, par_typ,
	input wire sampled_bit,
	input wire [7:0] data,
	output reg par_err
	);


always @(*) begin
	if (par_chk_en & !par_typ) begin
		par_err=(sampled_bit != ^data);
	end
	else if (par_chk_en /* & par_typ */) begin
		par_err=(sampled_bit == ^data);
	end
	else begin 
		par_err=1'b0;
	end
end
endmodule