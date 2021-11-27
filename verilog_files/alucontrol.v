module alucontrol(operation, funct, ALUOp);
    output [2:0] operation;
    input [5:0] funct;
    input [1:0] ALUOp;
    assign operation[2] = (ALUOp[1] & funct[1]) | ALUOp[0];
    assign operation[1] = (~ALUOp[1]) | (~funct[2]);
    assign operation[0] = (funct[3] | funct[0]) & ALUOp[1]; 
endmodule

module ALUctrlTest;
    reg [5:0] funct;
    wire [2:0] operation;
    reg [1:0] ALUOp;
    alucontrol a1(operation,funct,ALUOp);
    initial 
        begin
            $monitor($time,"\t funct=%b \t APUOp=%b \t operation=%b\n",funct,ALUOp,operation);
            #0 funct=6'b000000; ALUOp=2'b00;
            #10 funct=6'b000000; ALUOp=2'b01;
            #10 funct=6'b000000; ALUOp=2'b10; 
            #10 funct=6'b000010; ALUOp=2'b10;
            #10 funct=6'b000100; ALUOp=2'b10;
            #10 funct=6'b000101; ALUOp=2'b10;
            #10 funct=6'b001010; ALUOp=2'b10; 
        end
endmodule