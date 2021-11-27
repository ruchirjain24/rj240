`include "bigmux.v"
module bit32AND (out,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    assign {out}=in1 &in2;
endmodule

module bit32OR (out,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    assign {out}=in1 | in2;
endmodule

module FA_dataflow (Cout, Sum,In1,In2,Cin);
    input In1,In2;
    input Cin;
    output Cout;
    output Sum;
    assign {Cout,Sum}=In1+In2+Cin;
endmodule

module bit8_FA_dataflow(cout,sum,in1,in2,cin);
    input [7:0] in1,in2;
    input cin;
    output [7:0] sum;
    output cout;
    wire c1,c2,c3,c4,c5,c6,c7;
    FA_dataflow f1(c1,sum[0],in1[0],in2[0],cin);
    FA_dataflow f2(c2,sum[1],in1[1],in2[1],c1);
    FA_dataflow f3(c3,sum[2],in1[2],in2[2],c2);
    FA_dataflow f4(c4,sum[3],in1[3],in2[3],c3);
    FA_dataflow f5(c5,sum[4],in1[4],in2[4],c4);
    FA_dataflow f6(c6,sum[5],in1[5],in2[5],c5);
    FA_dataflow f7(c7,sum[6],in1[6],in2[6],c6);
    FA_dataflow f8(cout,sum[7],in1[7],in2[7],c7);
endmodule

module bit32_FA_dataflow(cout,sum,in1,in2,cin);
    input [31:0] in1,in2;
    input cin;
    output [31:0] sum;
    output cout;
    wire c1,c2,c3;
    bit8_FA_dataflow f1(c1,sum[7:0],in1[7:0],in2[7:0],cin);
    bit8_FA_dataflow f2(c2,sum[15:8],in1[15:8],in2[15:8],c1);
    bit8_FA_dataflow f3(c3,sum[23:16],in1[23:16],in2[23:16],c2);
    bit8_FA_dataflow f4(cout,sum[31:24],in1[31:24],in2[31:24],c3);
endmodule

module ALU(cout,result,in1,in2,op,bi);
    output [31:0] result;
    input [31:0] in1,in2;
    input bi;
    input [1:0] op;
    output cout;
    wire [31:0] wAnd,wOr,wAdd,wMux,notB;
    assign {notB}= ~in2;
    bit32AND b1(wAnd,in1,in2);
    bit32OR o1(wOr,in1,in2);
    bit32_2to1mux m1(wMux,bi,in2,notB);
    bit32_FA_dataflow fa1(cout,wAdd,in1,wMux,bi);
    bit32_4to1mux m2(result,op,wAnd,wOr,wAdd,32'h 00000000);
endmodule

module tbALU;
    reg bi;
    reg [1:0] op;
    reg [31:0] in1,in2;
    wire [31:0] result;
    wire cout;
    ALU a1(cout,result,in1,in2,op,bi);
    initial
        begin
            $monitor($time," in1=%h\t in2=%h\t op=%b\t bi=%b\t result=%h\t cout=%b\n",in1,in2,op,bi,result,cout);
            #0 in1=32'h00000005;    in2=32'h00000002;   op=2'b00;   bi=1'b0;
            #100 op=2'b01;
            #100 op=2'b10;
            #100 bi=1'b1;
            #200 $finish;
        end
endmodule