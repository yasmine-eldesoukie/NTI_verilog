module UART_RX #(parameter CLKS_PER_BIT= 5208)(
 input wire clk, rst, soft_rst,
 input wire tx_data_out,
 output reg rx_busy, rx_done, error,
 output reg [7:0] rx_data_out
);

localparam 
  IDLE= 3'b000,
  START= 3'b001,
  DATA= 3'b011,
  ERROR= 3'b010,
  DONE= 3'b111;


reg [$clog2(CLKS_PER_BIT):0] clk_counter;
reg [2:0] bit_counter;
reg [2:0] cs, ns;
reg bit_counter_done, clk_counter_done;
reg bit_counter_en, clk_counter_en, sample_en;


//baud counter
 always @(posedge clk or negedge rst) begin
    if (!rst) begin
        clk_counter<= CLKS_PER_BIT-1;
        clk_counter_done <=1'b0;
    end
    else if (soft_rst) begin
        clk_counter<= CLKS_PER_BIT-1;
        clk_counter_done <=1'b0;
    end
    else if (clk_counter== 'b0) begin
        clk_counter<= CLKS_PER_BIT-1;
        clk_counter_done<= 1'b1;
    end
    else if (clk_counter_en) begin
        clk_counter<= clk_counter -1;
        clk_counter_done<= 1'b0;
    end
 end

 //bit counter for DATA state
 always @(posedge clk or negedge rst) begin
    if (!rst) begin
        bit_counter<= 'b0;
        bit_counter_done <=1'b0;
    end
    else if (soft_rst) begin
        bit_counter<= 'b0;
        bit_counter_done <=1'b0;
    end
    else if (cs != DATA) begin
        bit_counter_done<= 1'b0; //turn it off after DATA is done so that it doesn't end the DATA state in the next frame by mistake
    end
    else if (bit_counter==7 && clk_counter_done) begin
        bit_counter<= 'b0;
        bit_counter_done<= 1'b1;
    end
    else if (bit_counter_en && clk_counter_done) begin
        bit_counter<= bit_counter +1;
        bit_counter_done<= 1'b0;
    end
 end
 
 //shift register
 always @(posedge clk or negedge rst) begin
    if (!rst) begin
        rx_data_out <='b0;
    end
    else if (soft_rst) begin
        rx_data_out <='b0;
    end
    else if (sample_en && ns==DATA) begin //ns not cs so that the stop bit doesn't overwrite the data reg
        rx_data_out <= {tx_data_out,rx_data_out[7:1]};
    end
 end

 //////// FSM //////// 
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
            if (!tx_data_out) begin
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
            if (bit_counter_done && sample_en && tx_data_out==1'b1) begin
                ns= DONE;
            end
            else if (bit_counter_done && sample_en && tx_data_out==1'b0) begin
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
 always @(*) begin
    rx_busy= (cs==START || cs==DATA );
    rx_done= (cs==DONE);
    error= (cs==ERROR);
    clk_counter_en= (ns==START || ns==DATA);
    bit_counter_en= (cs==DATA && clk_counter_done); //this means bit 0 has been sampled, since bit_counter already starts at 0 , if updated with ns==data, counter never stops
    sample_en= (clk_counter== ((CLKS_PER_BIT/2)-1));
 end    

endmodule