`timescale 1ns/1ps
module UART_TX_TB #(parameter PERIOD=5);
//signal declaration
reg [7:0] p_data_tb;
reg data_valid_tb, clk, rst;
//reg par_en_tb, par_typ_tb;
reg tx_out_expec ;
wire tx_out_dut, busy_dut, uart_tx_done_dut; //note: neither busy nor done signals are tested

reg [9:0] tx_out_reg;
reg [3:0] x; 
/* comment on x signal :
  x is to be chosen randomly, it is used to indicate when the data_valid signal will be high again after end of transmission in test case 3 
  x is also used to determine the length of the expected frame (10 or 11) depending on par_en value in test case 4
*/

//instantiation
UART_TX_TOP dut (
	.clk(clk),
	.rst(rst),
	.p_data(p_data_tb),
	.data_valid(data_valid_tb),
	//.par_en(par_en_tb),
	//.par_typ(par_typ_tb),
	.tx_out(tx_out_dut),
	.busy(busy_dut),
	.uart_tx_done(uart_tx_done_dut)
);
//clk generation
always #(5/2) clk=~clk;
/*
//stimulus generation in case of a parity bit
integer i,j;
initial begin
	$dumpfile("UART_TX.vcd");
	$dumpvars;

    clk=1'b0;
    rst=1'b0;
    repeat (20) @(negedge clk);

///////// Test case 1: Reset dominance /////////
    for (i=0; i<50 ; i=i+1) begin
        @(negedge clk);
    	par_en_tb =$random;
    	par_typ_tb=$random;
    	p_data_tb=$random;
    	data_valid_tb=1'b1;
    end

///////// Test case 2: Data_valid dominance /////////
    @(negedge clk);
    rst=1'b1;
    data_valid_tb=1'b0;

    for (i=0; i<50 ; i=i+1) begin
        @(negedge clk);
    	par_en_tb =$random;
    	par_typ_tb=$random;
    	p_data_tb=$random;
    end

///////// Test case 3: Normal functionality /////////
    for (i=0 ; i<400 ; i=i+1) begin
    	if (i<100) begin
    		par_en_tb =1'b0;
    	end
    	else if (i<200) begin
    		par_en_tb =1'b1;
    		par_typ_tb=1'b0;
    	end
    	else if (i<300) begin
    		par_en_tb =1'b1;
    		par_typ_tb=1'b1;
    	end
    	else begin
    		par_en_tb =$random;
    		par_typ_tb=$random;
    	end

    	p_data_tb=$random;
    	data_valid_tb=1'b1;
    	//generating expected output
    	if (par_en_tb & par_typ_tb) 
    			tx_out_reg={1'b1,(~^p_data_tb),p_data_tb,1'b0};
    	else if (par_en_tb & !par_typ_tb)
    			tx_out_reg={1'b1, (^p_data_tb),p_data_tb,1'b0};
    	else 
    	        tx_out_reg={2'b11             ,p_data_tb,1'b0};
    	
    	@(negedge clk);
    	data_valid_tb=1'b0;
    	//checking
    	x=$random;

    	for (j=0; j<(x+11) ; j=j+1 ) begin
    		tx_out_expec=tx_out_reg[j];
    		if (tx_out_dut != tx_out_expec) begin
    			$display("ERROR IN tx_out,1");
    			$stop;
    		end
    		@(negedge clk);
    	end
    end

    ////////////// reset on ////////////////
    rst=1'b0;
    repeat (20) @(negedge clk);
    rst=1'b1;
    ////////////// reset off ////////////////

///////// Test case 4 : data_valid high during transmission /////////
    for (i=0 ; i<100 ; i=i+1) begin
    	if (i<25) begin
    		par_en_tb =1'b0;
    	end
    	else if (i<50) begin
    		par_en_tb =1'b1;
    		par_typ_tb=1'b0;
    	end
    	else if (i<75) begin
    		par_en_tb =1'b1;
    		par_typ_tb=1'b1;
    	end
    	else begin
    		par_en_tb =$random;
    		par_typ_tb=$random;
    	end

    	p_data_tb=$random;
    	data_valid_tb=1'b1;
    	// ------- generating expected output -------
    	if (par_en_tb & par_typ_tb) 
    			tx_out_reg={1'b1,(~^p_data_tb),p_data_tb,1'b0};
    	else if (par_en_tb & !par_typ_tb)
    			tx_out_reg={1'b1, (^p_data_tb),p_data_tb,1'b0};
    	else 
    	        tx_out_reg={1'b1              ,p_data_tb,1'b0};
    	
    	@(negedge clk);
    	data_valid_tb=1'b0;

    	// ---------------- checking ----------------
    	x=(par_en_tb)? 4'd11 : 4'd10;

    	for (j=0; j<x ; j=j+1 ) begin
    		tx_out_expec=tx_out_reg[j];
            
            //toggle data_valid signal
            if (j%2==0)
                data_valid_tb=~data_valid_tb;

    		if (tx_out_dut != tx_out_expec) begin
    			$display("ERROR IN tx_out,2");
    			$stop;
    		end
    		/*
			comment on delay: 
    		  when transmission ends, data_valid signal is high so UART_TX starts another frame...
    		  when the last bit of the tx_out_expec is delayed, the expected output is delayed 1 clk --> results in ERROR...
    		  for that delay is activated except for the last bit. 
			// put the end of the comment here "astrik/""
    		 
    		if (j!=x-1) 
    		@(negedge clk);
    	end
    end

    @(negedge clk);
    $stop;

end
*/

//stimulus generation in case of a parity bit
integer i,j;
initial begin
	$dumpfile("UART_TX.vcd");
	$dumpvars;

    clk=1'b0;
    rst=1'b0;
    repeat (20) @(negedge clk);

///////// Test case 1: Reset dominance /////////
    for (i=0; i<50 ; i=i+1) begin
        @(negedge clk);
    	p_data_tb=$random;
    	data_valid_tb=1'b1;
    end

///////// Test case 2: Data_valid dominance /////////
    @(negedge clk);
    rst=1'b1;
    data_valid_tb=1'b0;

    for (i=0; i<50 ; i=i+1) begin
        @(negedge clk);
    	p_data_tb=$random;
    end

///////// Test case 3: Normal functionality /////////
    for (i=0 ; i<400 ; i=i+1) begin
    	p_data_tb=$random;
    	data_valid_tb=1'b1;
    	//generating expected output
    	tx_out_reg={1'b1             ,p_data_tb,1'b0};
    	
    	//@(negedge clk);
    	//data_valid_tb=1'b0;
    	//checking
    	//x=$random;

    	for (j=0; j<10 ; j=j+1 ) begin
    		tx_out_expec=tx_out_reg[j];
			repeat (5208) @(negedge clk);
    		if (tx_out_dut != tx_out_expec) begin
    			$display("ERROR IN tx_out,1");
    			$stop;
    		end
    		@(negedge clk);
			data_valid_tb=1'b0;
    	end
        
    end

    ////////////// reset on ////////////////
    rst=1'b0;
    repeat (20) @(negedge clk);
    rst=1'b1;
    ////////////// reset off ////////////////

/*
///////// Test case 4 : data_valid high during transmission /////////
    for (i=0 ; i<100 ; i=i+1) begin
    	p_data_tb=$random;
    	data_valid_tb=1'b1;
    	// ------- generating expected output -------
    	tx_out_reg={1'b1              ,p_data_tb,1'b0};
    	
    	@(negedge clk);
    	data_valid_tb=1'b0;

    	// ---------------- checking ----------------

    	for (j=0; j<10 ; j=j+1 ) begin
    		tx_out_expec=tx_out_reg[j];
            
            //toggle data_valid signal
            if (j%2==0)
                data_valid_tb=~data_valid_tb;

    		if (tx_out_dut != tx_out_expec) begin
    			$display("ERROR IN tx_out,2");
    			$stop;
    		end
    		/*
			comment on delay: 
    		  when transmission ends, data_valid signal is high so UART_TX starts another frame...
    		  when the last bit of the tx_out_expec is delayed, the expected output is delayed 1 clk --> results in ERROR...
    		  for that delay is activated except for the last bit. 
			// put astrik / if you don't comment the test case
    		 
    		if (j!=x-1) begin
    		   @(negedge clk);
			end
    	end
    end */

    @(negedge clk);
    $stop;

end
endmodule