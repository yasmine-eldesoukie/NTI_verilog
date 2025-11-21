module parity_check_tb ();
//signal declaration
reg par_typ_tb , par_chk_en_tb , clk, rst; 
reg sampled_bit_tb;
reg [7:0] data_frame_d_tb; //the 8 data bits
reg [8:0] data_frame_p_tb; //the 8 data bits and the parity bit
wire par_err_dut;

reg par_err_expected;
reg [2:0] x;

//instantiation
parity_check dut (
	.par_typ(par_typ_tb),
	.par_chk_en(par_chk_en_tb),
	.clk(clk),
	.rst(rst),
	.sampled_bit(sampled_bit_tb),
	.par_err(par_err_dut)
);

//clk generation
initial begin
	clk=1'b0;
	forever #1 clk=~clk;
end

//stimulus generation 
integer i,j;
initial begin
	rst=1'b0;
	repeat (20) @(negedge clk);

	//Reset on , enable on
	par_chk_en_tb=1'b1;
	for (i=0; i<100; i=i+1) begin
	    @ (negedge clk);
		data_frame_p_tb=$random;
		par_typ_tb=$random;

		for (j=0; j<9; j=j+1) begin
			sampled_bit_tb=data_frame_p_tb[j];
		    @(negedge clk);
		end
    end

    //Reset off , enable off
    @(negedge clk);
	rst=1'b1;
	par_chk_en_tb=1'b0;

	for (i=0; i<400; i=i+1) begin
		data_frame_p_tb=$random;
		par_typ_tb=$random;

		for (j=0; j<9; j=j+1) begin
			sampled_bit_tb=data_frame_p_tb[j];
		    @(negedge clk);
		end
    end
    
    //Reset off , enable on
    @(negedge clk);
	par_chk_en_tb=1'b1;
	
	for (i=0; i<400; i=i+1) begin
		data_frame_d_tb=$random;
		if(i<100) begin
		    par_typ_tb=1'b0;
		    data_frame_p_tb={^data_frame_d_tb,data_frame_d_tb};
		    par_err_expected=1'b0;
		end
		else if(i<200) begin
		    //par_typ_tb=1'b0;
		    data_frame_p_tb={~(^data_frame_d_tb),data_frame_d_tb};
		    par_err_expected=1'b1;
		end
		else if(i<300) begin
		    par_typ_tb=1'b1;
		    data_frame_p_tb={~(^data_frame_d_tb),data_frame_d_tb};
		    par_err_expected=1'b0;
		end
		else begin
			//par_typ_tb=1'b1;
		    data_frame_p_tb={^data_frame_d_tb,data_frame_d_tb};
		    par_err_expected=1'b1;
		end
		for (j=0; j<9; j=j+1) begin
			sampled_bit_tb=data_frame_p_tb[j];
		    @(negedge clk);
		end
		
		if (par_err_dut!= par_err_expected) begin
			$display("ERROR %d",i);
			$stop;
		end
 
        //to test functionality if frames are consecutive or not
        par_chk_en_tb=1'b0;
		x=$random;
		repeat (x) @(negedge clk); 
        par_chk_en_tb=1'b1;
	end

    $stop;
end
endmodule