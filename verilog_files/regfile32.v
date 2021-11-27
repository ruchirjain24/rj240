module d_ff_RF(q,d,clock,reset);
    input d,clock,reset;
    output q;
    reg q;
    always @(posedge clock or negedge reset)
        if(~reset)
            q=1'b0;
        else
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

module AND_5_input(g,a,b,c,d,e);
    output g;
    input a,b,c,d,e;
    and #(50) and1(f1,a,b,c,d), and2(g,f1,e);
endmodule

module dec5to32(Out,Adr);
    input [4:0] Adr; // Adr=Address of register
    output [31:0] Out;
    not #(50) Inv4(Nota, Adr[4]);
    not #(50) Inv3(Notb, Adr[3]);
    not #(50) Inv2(Notc, Adr[2]);
    not #(50) Inv1(Notd, Adr[1]);
    not #(50) Inv0(Note, Adr[0]);

    AND_5_input a0(Out[0],  Nota,Notb,Notc,Notd,Note); // 00000
    AND_5_input a1(Out[1],  Nota,Notb,Notc,Notd,Adr[0]); // 00001
    AND_5_input a2(Out[2],  Nota,Notb,Notc,Adr[1],Note); //00010
    AND_5_input a3(Out[3],  Nota,Notb,Notc,Adr[1],Adr[0]);
    AND_5_input a4(Out[4],  Nota,Notb,Adr[2],Notd,Note);
    AND_5_input a5(Out[5],  Nota,Notb,Adr[2],Notd,Adr[0]);
    AND_5_input a6(Out[6],  Nota,Notb,Adr[2],Adr[1],Note);
    AND_5_input a7(Out[7],  Nota,Notb,Adr[2],Adr[1],Adr[0]);
    AND_5_input a8(Out[8],    Nota,Adr[3],Notc,Notd,Note);
    AND_5_input a9(Out[9],    Nota,Adr[3],Notc,Notd,Adr[0]);
    AND_5_input a10(Out[10],  Nota,Adr[3],Notc,Adr[1],Note);
    AND_5_input a11(Out[11],  Nota,Adr[3],Notc,Adr[1],Adr[0]);
    AND_5_input a12(Out[12],  Nota,Adr[3],Adr[2],Notd,Note);
    AND_5_input a13(Out[13],  Nota,Adr[3],Adr[2],Notd,Adr[0]);
    AND_5_input a14(Out[14],  Nota,Adr[3],Adr[2],Adr[1],Note);
    AND_5_input a15(Out[15],  Nota,Adr[3],Adr[2],Adr[1],Adr[0]);
    AND_5_input a16(Out[16],  Adr[4],Notb,Notc,Notd,Note);
    AND_5_input a17(Out[17],  Adr[4],Notb,Notc,Notd,Adr[0]);
    AND_5_input a18(Out[18],  Adr[4],Notb,Notc,Adr[1],Note);
    AND_5_input a19(Out[19],  Adr[4],Notb,Notc,Adr[1],Adr[0]);
    AND_5_input a20(Out[20],  Adr[4],Notb,Adr[2],Notd,Note);
    AND_5_input a21(Out[21],  Adr[4],Notb,Adr[2],Notd,Adr[0]);
    AND_5_input a22(Out[22],  Adr[4],Notb,Adr[2],Adr[1],Note);
    AND_5_input a23(Out[23],  Adr[4],Notb,Adr[2],Adr[1],Adr[0]);
    AND_5_input a24(Out[24],  Adr[4],Adr[3],Notc,Notd,Note);
    AND_5_input a25(Out[25],  Adr[4],Adr[3],Notc,Notd,Adr[0]);
    AND_5_input a26(Out[26],  Adr[4],Adr[3],Notc,Adr[1],Note);
    AND_5_input a27(Out[27],  Adr[4],Adr[3],Notc,Adr[1],Adr[0]);
    AND_5_input a28(Out[28],  Adr[4],Adr[3],Adr[2],Notd,Note);
    AND_5_input a29(Out[29],  Adr[4],Adr[3],Adr[2],Notd,Adr[0]);
    AND_5_input a30(Out[30],  Adr[4],Adr[3],Adr[2],Adr[1],Note);
    AND_5_input a31(Out[31],  Adr[4],Adr[3],Adr[2],Adr[1],Adr[0]); // 11111
endmodule

module mux32_1_RF(out,d,sel);
    input [31:0][31:0] d;
    input [4:0] sel;
    output [31:0] out;
    reg [31:0] out;
    always @(d or sel)
        case(sel)
            5'b00000:  out=d[0];
            5'b00001:  out=d[1];
            5'b00010:  out=d[2];
            5'b00011:  out=d[3];
            5'b00100:  out=d[4];
            5'b00101:  out=d[5];
            5'b00110:  out=d[6];
            5'b00111:  out=d[7];
            5'b01000:  out=d[8];
            5'b01001:  out=d[9];
            5'b01010:  out=d[10];
            5'b01011:  out=d[11];
            5'b01100:  out=d[12];
            5'b01101:  out=d[13];
            5'b01110:  out=d[14];
            5'b01111:  out=d[15];
            5'b10000:  out=d[16];
            5'b10001:  out=d[17];
            5'b10010:  out=d[18];
            5'b10011:  out=d[19];
            5'b10100:  out=d[20];
            5'b10101:  out=d[21];
            5'b10110:  out=d[22];
            5'b10111:  out=d[23];
            5'b11000:  out=d[24];
            5'b11001:  out=d[25];
            5'b11010:  out=d[26];
            5'b11011:  out=d[27];
            5'b11100:  out=d[28];
            5'b11101:  out=d[29];
            5'b11110:  out=d[30];
            5'b11111:  out=d[31];
        endcase
endmodule

module RegFile_4(ReadData1,ReadData2,clock,reset,RegWrite,ReadReg1,ReadReg2,WriteRegNo, WriteData);
    input [4:0] ReadReg1,ReadReg2,WriteRegNo;
    input clock,reset,RegWrite;
    output [31:0] ReadData1,ReadData2;
    input [31:0] WriteData;

    wire [31:0] Decode;
    wire c[31:0];
    wire [31:0][31:0] w;

    dec5to32 dec(Decode, WriteRegNo);
    genvar j;
    generate
        for (j = 0;j<32 ;j=j+1 ) begin: d_loopi
            and g(c[j],RegWrite,Decode[j],clock);
            reg_32bit r(w[j],WriteData,c[j],reset);
        end
    endgenerate

    mux32_1_RF m0(ReadData1,w,ReadReg1);
    mux32_1_RF m1(ReadData2,w,ReadReg2);
endmodule
