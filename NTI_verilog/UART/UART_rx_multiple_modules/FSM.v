module FSM #(parameter CLKS_PER_BIT= 5208)(
	input wire clk, rst, soft_rst,
	input wire rx_data_in,
	input wire [$clog2(CLKS_PER_BIT)-1:0] clk_counter,
	input wire [2:0] bit_counter,
	input wire clk_counter_done,
	output reg clk_counter_en, bit_counter_en, shift_register_en,
	output reg rx_busy, rx_done, error
	);

localparam 
  IDLE= 3'b000,
  START= 3'b001,
  DATA= 3'b011,
  ERROR= 3'b010,
  DONE= 3'b111;

reg sample_en, bit_counter_done;
reg [2:0] cs, ns;

//current state
 always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cs<= IDLE;
    end
    else if (soft_rst) begin
        cs<= IDLE;
    end
    else begin
        cs<= ns;
    end
 end

 //next state logic
 always @(*) begin
    case (cs)
        IDLE: begin
            if (!rx_data_in) begin
                ns= START;
            end
            else begin
                ns= IDLE;
            end
        end

        START: begin
            if (clk_counter_done) begin
                ns= DATA;
            end
            else begin
                ns= START;
            end
        end

        DATA: begin
            if (bit_counter_done && sample_en && rx_data_in==1'b1) begin
                ns= DONE;
            end
            else if (bit_counter_done && sample_en && rx_data_in==1'b0) begin
                ns= ERROR;
            end
            else begin
                ns= DATA;
            end
        end

        ERROR: begin
            ns= ERROR;
        end

        DONE: begin
            ns= IDLE;
        end

        default: begin
            ns= IDLE;
        end
    endcase
 end

 //output logic 
 //combinational
 always @(*) begin
    rx_busy= (cs==START || cs==DATA );
    rx_done= (cs==DONE);
    error= (cs==ERROR);
    clk_counter_en= (ns==START || ns==DATA);
    bit_counter_en= (cs==DATA && clk_counter_done); //this means bit 0 has been sampled, since bit_counter already starts at 0 , if updated with ns==data, counter never stops
    sample_en= (clk_counter== ((CLKS_PER_BIT/2)-1));
    shift_register_en= (sample_en && ns==DATA); //ns not cs so that the stop bit doesn't overwrite the data reg
 end   

 //sequential
 always @(posedge clk or negedge rst) begin
     if (!rst) begin
         bit_counter_done<=1'b0;
     end
     else if (soft_rst) begin
         bit_counter_done<= 1'b0;
     end
     else if (bit_counter_done && cs!= DATA) begin
         bit_counter_done<=1'b0;
     end
     else if (bit_counter==7 && clk_counter_done) begin
         bit_counter_done<= 1'b1;
     end
 end 

 endmodule