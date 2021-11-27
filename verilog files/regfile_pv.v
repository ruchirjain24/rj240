`include "reg_32bit.v"
`include "mux4_1.v"
`include "decoder_2to4.v"

module RegFile(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);
	input clk, reset;
	output [31:0] ReadData1, ReadData2;
	input [1:0] ReadReg1, ReadReg2;
	input [31:0] WriteData;
	input [1:0] WriteReg;
	input RegWrite;
	wire [31:0] q1,q2,q3,q4;
	wire [0:3] register;
	
	wire clk1,clk2,clk3,clk4;
	decoder2_4 mydecoder(register,WriteReg);
	
	and(clk1,clk,RegWrite,register[0]);
	and(clk2,clk,RegWrite,register[1]);
	and(clk3,clk,RegWrite,register[2]);
	and(clk4,clk,RegWrite,register[3]);
	
	reg_32bit reg1(q1,WriteData,clk1,reset);
	reg_32bit reg2(q2,WriteData,clk2,reset);
	reg_32bit reg3(q3,WriteData,clk3,reset);
	reg_32bit reg4(q4,WriteData,clk4,reset);
	
	mux4_1 mux1(ReadData1,q1,q2,q3,q4,ReadReg1);
	mux4_1 mux2(ReadData2,q1,q2,q3,q4,ReadReg2);
	
endmodule;

module tb32reg;
	
	reg clk,reset;
	reg [1:0] ReadReg1, ReadReg2;
	reg [31:0] WriteData;
	reg [1:0] WriteReg;
	reg RegWrite;
	wire [31:0] ReadData1, ReadData2;
	
	RegFile myfile(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);
	
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
	
	#2 $display("Writing to reg 3");
	WriteData = 32'd453;
	WriteReg = 2'b10;
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
	
	#2 $display("Writing to reg 4");
	WriteData = 32'd30;
	WriteReg = 2'b11;
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
	
	#200 $finish;
	end
	
	always @(clk)
	#5 clk <=~clk;
	
	
endmodule
	
	