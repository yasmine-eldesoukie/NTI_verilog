module UART_TX_FSM 
#(parameter 
	CLK_PER_BIT= 5208, //50 mega divided 9600 Hz //since the FPGA clk is 50 Mhz and UART is 9600
	CLK_COUNTER_WIDTH= $clog2(CLK_PER_BIT)
)
(
input wire clk, rst,
input wire data_valid, ser_done, 
//input wire par_en,
output reg ser_en, busy,
output reg uart_tx_done,
output reg [1:0] mux_sel
);

parameter 
	IDLE=3'b000,
	START=3'b001,
	DATA=3'b011,
	//PARITY=3'b010,
	STOP=3'b110;

reg [CLK_COUNTER_WIDTH-1:0] clk_counter;
reg [2:0] cs,ns;

always @(negedge clk or negedge rst) begin
	if (!rst) begin
		clk_counter<='b0;
	end
	else if (clk_counter==CLK_PER_BIT) begin
		clk_counter<= 'b0;
	end
	else if (ns==START | ns==STOP) begin
		clk_counter <= clk_counter+1;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) 
	  cs<=IDLE;
	else 
	  cs<=ns;
end

always @(*) begin
	case(cs)
	IDLE: begin
		if (data_valid) 
		   ns=START;
		else 
		   ns= IDLE;
	end 

	START: begin
		   ns= (clk_counter == CLK_PER_BIT)? DATA: START;
	end

	DATA: begin
		/* //if there's a parity bit
		if (ser_done & par_en)
           ns=PARITY;
        else if (ser_done & !par_en)
           ns=STOP;
        else 
           ns=DATA;
		*/
		if (ser_done & clk_counter == CLK_PER_BIT ) begin
			ns=STOP;
		end
		else begin
			ns=DATA;
		end
	end

	STOP: begin
		if (data_valid & clk_counter == CLK_PER_BIT) 
		   ns=START;
		else 
		   ns=IDLE;
	end

	default: begin
		   ns=IDLE;
	end

	endcase
end

/////////// output logic ///////////

//done signal : after stop bit
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		uart_tx_done <= 1'b0; 
	end
	else if (cs==STOP) begin
		uart_tx_done <= 1'b1;
	end
	else begin
		uart_tx_done <= 1'b0;
	end
end

//the rest of the signals
always @(*) begin
	ser_en=1'b0;
	busy=1'b0;
	mux_sel=2'b01;

	case (cs)
	START: begin
		ser_en=1'b1;
		busy=1'b1;
		mux_sel=2'b00;
	end 

	DATA: begin
		ser_en=1'b1;
		busy=1'b1;
		mux_sel=2'b10;
	end 

	/*PARITY: begin
		ser_en=1'b0;
		busy=1'b1;
		mux_sel=2'b11;
	end 
	*/

	STOP: begin
		ser_en=1'b0;
		busy=1'b1;
		mux_sel=2'b01;
	end 

	default: begin
		ser_en=1'b0;
		busy=1'b0;
		mux_sel=2'b01;
	end
	endcase
end

endmodule