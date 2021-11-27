`include "1b_fulladder.v"
module eightFADDER(R,c_out,A,B);
    input [0:7]A;
    input [0:7]B;
    output [0:7]R;
    output c_out;
    
    wire v0,v1,v2,v3,v4,v5,v6;
    reg iti;
    initial begin
        iti=1'b0;
    end
    
    FADDER f7(R[7], v0, A[7], B[7], iti);
    FADDER f6(R[6], v1, A[6], B[6], v0);
    FADDER f5(R[5], v2, A[5], B[5], v1);
    FADDER f4(R[4], v3, A[4], B[4], v2);
    FADDER f3(R[3], v4, A[3], B[3], v3);
    FADDER f2(R[2], v5, A[2], B[2], v4);
    FADDER f1(R[1], v6, A[1], B[1], v5);
    FADDER f0(R[0], c_out, A[0], B[0], v6);
endmodule

module testeightadd;
    reg [0:7]x;
    reg [0:7]y;
    wire [0:7]s;
    wire c_out;
    eightFADDER ef1(s,c_out,x,y);

    initial
        begin
            $dumpfile("8b_fulladder.hello");
            $dumpvars(0,ef1);
            $monitor(" x=%b, y=%b, s=%b, c_out=%b",x,y,s,c_out);
            #0 x=8'b00000000;  y=8'b00000000;
            #2 x=8'b11100000;  y=8'b00000110;
            #2 $finish;
        end
endmodule
