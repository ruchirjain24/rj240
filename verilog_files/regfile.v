module d_ff_RF(q,d,clock,reset);
    input d,clock,reset;
    output q;
    reg q;
    always @(posedge clock or negedge reset)
        if(~reset)
            q=1'b0;
        else if(clock)
            q=d;
endmodule

module reg_32bit(q,d,clock,reset);
    input [31:0] d;
    input clock,reset;
    output [31:0] q;
    genvar j;
    generate
        for (j = 0;j<32 ;j=j+1 ) begin: d_loop
            d_ff_RF ff(q[j],d[j],clock,reset);
        end
    endgenerate
endmodule

module decoder2_4(out,in);
    input [1:0] in;
    output [3:0] out;
    assign out[0]=(~in[1] & ~in[0]),
            out[1]=(~in[1] & in[0]),
            out[2]=(in[1] & ~in[0]),
            out[3]=(in[1] & in[0]);
endmodule

module mux4_1_RF(out,d0,d1,d2,d3,sel);
    input [31:0] d0,d1,d2,d3;
    input [1:0] sel;
    output [31:0] out;
    reg [31:0] out;
    always @(d0 or d1 or d2 or d3 or sel)
        case(sel)
            2'b00:  out=d0;
            2'b01:  out=d1;
            2'b10:  out=d2;
            2'b11:  out=d3;
        endcase
endmodule

module RegFile_4(ReadData1,ReadData2,clock,reset,RegWrite,ReadReg1,ReadReg2,WriteRegNo, WriteData);
    input [1:0] ReadReg1,ReadReg2,WriteRegNo;
    input clock,reset,RegWrite;
    output [31:0] ReadData1,ReadData2;
    input [31:0] WriteData;

    wire [3:0] Decode;
    wire c0,c1,c2,c3;

    decoder2_4 dec(Decode, WriteRegNo);

    and g0(c0,RegWrite,Decode[0],clock);
    and g1(c1,RegWrite,Decode[1],clock);
    and g2(c2,RegWrite,Decode[2],clock);
    and g3(c3,RegWrite,Decode[3],clock);

    wire [31:0] w0,w1,w2,w3;
    reg_32bit r0(w0,WriteData,c0,reset);
    reg_32bit r1(w1,WriteData,c1,reset);
    reg_32bit r2(w2,WriteData,c2,reset);
    reg_32bit r3(w3,WriteData,c3,reset);

    mux4_1_RF m0(ReadData1,w0,w1,w2,w3,ReadReg1);
    mux4_1_RF m1(ReadData2,w0,w1,w2,w3,ReadReg2);
endmodule

module tb32reg;
	
	reg clk,reset;
	reg [1:0] ReadReg1, ReadReg2;
	reg [31:0] WriteData;
	reg [1:0] WriteReg;
	reg RegWrite;
	wire [31:0] ReadData1, ReadData2;
	
	RegFile_4 myfile(ReadData1,ReadData2,clk,reset,RegWrite,ReadReg1,ReadReg2,WriteReg, WriteData);
	
	initial
        begin
        clk= 1'b1;
	
        #2 $display("Reading all the registers : ");
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b01;
        #2 $display ("Reg1 : %b", ReadData1);
        #2 $display ("Reg2 : %b", ReadData2);
        ReadReg1 = 2'b10;
        ReadReg2 = 2'b11;
        #2 $display ("Reg3 : %b", ReadData1);
        #2 $display ("Reg4 : %b", ReadData2);
        
        reset=1'b0;//reset the register
        
        
        #2 $display("After reset");
        #2 $display("Reading all the registers : ");
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b01;
        #2 $display ("Reg1 : %b", ReadData1);
        #2 $display ("Reg2 : %b", ReadData2);
        ReadReg1 = 2'b10;
        ReadReg2 = 2'b11;
        #2 $display ("Reg3 : %b", ReadData1);
        #2 $display ("Reg4 : %b", ReadData2);
        
        #20 reset=1'b1;
        
        #2 $display("Writing to reg 1");
        WriteData = 32'd13;
        WriteReg = 2'b00;
        RegWrite = 1;
        #5 RegWrite = 0;
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b01;
        #2 $display ("Reg1 : %b", ReadData1);
        #2 $display ("Reg2 : %b", ReadData2);
        ReadReg1 = 2'b10;
        ReadReg2 = 2'b11;
        #2 $display ("Reg3 : %b", ReadData1);
        #2 $display ("Reg4 : %b", ReadData2);
        
        #2 $display("Writing to reg 2");
        WriteData = 32'd3;
        WriteReg = 2'b01;
        RegWrite = 1;
        #5 RegWrite = 0;
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b01;
        #2 $display ("Reg1 : %b", ReadData1);
        #2 $display ("Reg2 : %b", ReadData2);
        ReadReg1 = 2'b10;
        ReadReg2 = 2'b11;
        #2 $display ("Reg3 : %b", ReadData1);
        #2 $display ("Reg4 : %b", ReadData2);
        
        #2 $display("Writing to reg 3 hello");
        WriteReg = 2'b10;
        RegWrite = 1;
        WriteData = 32'd1;

        RegWrite =#5 0;
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b01;
        $display ("Reg1 : %b", ReadData1);
        $display ("Reg2 : %b", ReadData2);
        ReadReg1 = 2'b10;
        ReadReg2 = 2'b11;
        $display ("Reg3 : %b", ReadData1);
        $display ("Reg4 : %b", ReadData2);
        
        #2 $display("Writing to reg 4");
        WriteData = 32'd30;
        WriteReg = 2'b11;
        RegWrite = 1;
        RegWrite = #5 0;
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b01;
        #2 $display ("Reg1 : %b", ReadData1);
        #2 $display ("Reg2 : %b", ReadData2);
        ReadReg1 = 2'b10;
        ReadReg2 = 2'b11;
        #2 $display ("Reg3 : %b", ReadData1);
        #2 $display ("Reg4 : %b", ReadData2);
        
        #200 $finish;
        end
	
	always @(clk)
	    #5 clk<=~clk;
	
	
endmodule