module jkfflop(input  J, K , clk ,rst, output reg Q); //synchronous reset, output has to be reg in behaviourial modelling
  always @(posedge clk) 
    begin
        if(rst)
            Q <= 1'b0;
        else 
            begin
                case({J,K})
                2'b00 : Q <= Q   ;  //same
                2'b01 : Q <= 1'b0;  //reset
                2'b10 : Q <= 1'b1;  //set
                2'b11 : Q <= ~Q  ;  //toggle
                endcase
            end
    end
endmodule