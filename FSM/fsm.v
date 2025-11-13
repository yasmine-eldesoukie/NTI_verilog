module fsm (
    input wire clk, rst,
    input wire a, b,
    output reg y0, y1
);
localparam
    S0= 2'b00,
    S1= 2'b10,
    S2= 2'b11; 

reg [1:0] cs, ns;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cs<= S0;
    end
    else begin
        cs<= ns;
    end 
end

always @(*) begin
    y0= 1'b0;
    case (cs) 
        S0: begin
            if (a&&b) begin
                ns= S2;
                y0= 1'b1;
                $display("s2");
            end
            else if (a && ~b) begin
                ns= S1;
                $display("s1");
            end
            else begin
                ns= S0;
                $display("s0");
            end        
        end

        S1: begin
            if (a) begin
                ns= S0;
                $display("s0");
            end
            else begin
                ns= S1;
                $display("s1");
            end
        end

        S2: begin
            ns= S0;
            $display("s0");
        end

        default: begin
            ns= S0;
            $display("s0");
            y0= 1'b0;
        end
    endcase
end

always @(*) begin
    y1= (cs== S0 | cs==S1);
end

endmodule