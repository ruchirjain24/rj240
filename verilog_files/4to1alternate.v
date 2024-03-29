module four_to_one_alt(out,in,sel);
input [0:3] in;
input [0:1] sel;
output out;
wire a,b,c,d,n1,n2,a1,a2,a3,a4;
not n(n1,sel[1]);
not nn(n2,sel[0]);
and (a1,in[3],n1,n2);
and (a2,in[2],n2,sel[1]);
and (a3,in[1],sel[0],n1);
and (a4,in[0],sel[0],sel[1]);
or or1(out,a4,a3,a2,a1);
endmodule