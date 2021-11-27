module seq_detect( clk, rst, inp, outp);
    input clk, rst, inp;
    output outp;
    reg [2:0] state;
    reg outp;
    always @( posedge clk, posedge rst ) 
        begin
            if( rst ) 
                begin
                    state <= 3'b000;
                    outp <= 0;
                end
            else 
                begin
                    case( state )
                        3'b000: 
                            begin
                                if( inp ) 
                                    begin
                                        state <= 3'b001;
                                        outp <= 0;
                                    end
                                else 
                                    begin
                                        state <= 3'b000;
                                        outp <= 0;
                                    end
                            end
                        3'b001: 
                            begin
                                if( inp ) 
                                    begin
                                        state <= 3'b001;
                                        outp <= 0;
                                    end
                                else 
                                    begin
                                        state <= 3'b010;
                                        outp <= 0;
                                    end
                            end
                        3'b010: 
                            begin
                                if( inp ) 
                                    begin
                                        state <= 3'b011;
                                        outp <= 0;
                                    end
                                else 
                                    begin
                                        state <= 3'b000;
                                        outp <= 0;
                                    end
                            end
                        3'b011: 
                            begin
                                if( inp ) 
                                    begin
                                        state <= 3'b100;
                                        outp <= 0;
                                    end
                                else 
                                    begin
                                        state <= 3'b010;
                                        outp <= 0;
                                    end
                            end
                        3'b100: 
                            begin
                                if( inp ) 
                                    begin
                                        state <= 3'b001;
                                        outp <= 0;
                                    end
                                else 
                                    begin
                                        state <= 3'b010;
                                        outp <= 1;
                                    end
                            end
                            
                        default: 
                            begin
                                state <= 3'b000;
                                outp <= 0;
                            end
                    endcase
                end
        end
endmodule
// Test Bench

module testDetectSeq;
    reg clk, rst, inp;
    wire outp;
    reg[15:0] sequence;
    integer i;
    seq_detect duty( clk, rst, inp, outp);
    initial
        begin
            clk = 0;
            rst = 1;
            sequence = 16'b0101_0110_1101_0010;
            #5 rst = 0;
            for( i = 0; i <= 15; i = i + 1)
                begin
                    inp = sequence[i];  //predecided sequence of length 16
                    #2 clk = 1;
                    #2 clk = 0;
                    $display("State = ", duty.state, " Input = ", inp, ", Output = ",outp);
                end
            testing;
        end
    task testing;
        for( i = 0; i <= 15; i = i + 1)
            begin
                inp = $random % 2;  //random sequence of for 16 times
                #2 clk = 1;
                #2 clk = 0;
                $display("State = ", duty.state, " Input = ", inp, ", Output =", outp);
            end
    endtask
endmodule