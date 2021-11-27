module DECODER(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
    input x,y,z;
    output d0,d1,d2,d3,d4,d5,d6,d7;
    wire x0,y0,z0;
    not n1(x0,x);
    not n2(y0,y);
    not n3(z0,z);
    and a0(d7,x0,y0,z0);//0
    and a1(d6,x0,y0,z); //1
    and a2(d5,x0,y,z0); //2
    and a3(d4,x0,y,z);  //3
    and a4(d3,x,y0,z0); //4
    and a5(d2,x,y0,z);  //5
    and a6(d1,x,y,z0);  //6
    and a7(d0,x,y,z);   //7
endmodule

module FADDER(s,c,x,y,z);
    input x,y,z;
    wire d0,d1,d2,d3,d4,d5,d6,d7;
    output s,c;
    DECODER dec(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
    assign s = d6 | d5 | d3 | d0, c = d4 | d2 | d1 | d0;
endmodule

// module testfulladd;
//     reg x,y,z;
//     wire s,c;
//     FADDER fl(s,c,x,y,z);
//     initial
//         $monitor($time," x=%b, y=%b, z=%b, s=%b, c=%b",x,y,z,s,c);
//     initial
//         begin
//             #0 x=1'b0;y=1'b0;z=1'b0;
//             #4 x=1'b1;y=1'b0;z=1'b0;
//             #4 x=1'b0;y=1'b1;z=1'b0;
//             #4 x=1'b1;y=1'b1;z=1'b0;
//             #4 x=1'b0;y=1'b0;z=1'b1;
//             #4 x=1'b1;y=1'b0;z=1'b1;
//             #4 x=1'b0;y=1'b1;z=1'b1;
//             #4 x=1'b1;y=1'b1;z=1'b1;
//         end
// endmodule
