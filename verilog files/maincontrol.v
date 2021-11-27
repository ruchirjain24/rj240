module ANDarray (RegDst,ALUSrc, MemtoReg, RegWrite,MemRead, MemWrite,Branch,ALUOp1,ALUOp0,Op);
    input [5:0] Op;
    output RegDst,ALUSrc,MemtoReg, RegWrite, MemRead,MemWrite,Branch,ALUOp1,ALUOp0;
    wire Rformat, lw,sw,beq;
    assign Rformat= (~Op[0])& (~Op[1])& (~Op[2])& (~Op[3])& (~Op[4])& (~Op[5]);
    assign lw = (Op[5])& (~Op[2])& (~Op[3])& (~Op[4])& (Op[0])& (Op[1]);
    assign sw= (Op[0])& (Op[1])& (~Op[2])& (Op[3])& (~Op[4])& (Op[5]);
    assign beq= (~Op[0])& (~Op[1])& (Op[2])& (~Op[3])& (~Op[4])& (~Op[5]);

    assign RegDst=Rformat;
    assign ALUSrc= lw | sw;
    assign MemtoReg= lw;
    assign RegWrite= Rformat | lw;
    assign MemRead= lw;
    assign MemWrite= sw;
    assign Branch= beq;
    assign ALUOp1= Rformat;
    assign ALUOp0= beq;
endmodule

module MCtest;
    reg [5:0] Op;
    wire RegDst,ALUSrc,MemtoReg, RegWrite, MemRead,MemWrite,Branch,ALUOp1,ALUOp0;
    ANDarray a1(RegDst,ALUSrc, MemtoReg, RegWrite,MemRead, MemWrite,Branch,ALUOp1,ALUOp0,Op);
    initial
        begin
            $monitor($time," Op=%b RegDst=%b ALUSrc=%b MemtoReg=%b RegWrite=%b MemRead=%b MemWrite=%b Branch=%b ALUOp1=%b ALUOp0=%b\n",Op,RegDst,ALUSrc,MemtoReg, RegWrite, MemRead,MemWrite,Branch,ALUOp1,ALUOp0);
            #0 Op=6'b000000;
            #100 Op=6'b100011;
            #100 Op=6'b101011;
            #100 Op=6'b000100;
            #200 $finish;
        end
endmodule
