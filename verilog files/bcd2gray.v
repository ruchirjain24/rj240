module bcd_to_gray_code_gate(a0,a1,a2,a3,b0,b1,b2,b3);
    input a0, a1, a2, a3;
    output b0, b1, b2, b3;
    wire c,d,e,f,g,h,i,j;

    and(b3,a3,a3);

    or(b2, a2,a3);

    not(c,a2);
    and(d,c,a1);
    not(e,a1);
    and(f,e,a2);
    or(b1,d,f);

    and(g,e,a0);
    not(h,a0);
    and(i,h,a1);
    or(b0,i,g);

endmodule

module bcd_to_gray_code_df(a0,a1,a2,a3,b0,b1,b2,b3);
    input a0,a1,a2,a3;
    output b0,b1,b2,b3;
    assign b3 = a3;
    assign b2 = a2 | a3;
    assign b1 = (~a2 & a1)| (~a1 & a2);
    assign b0 = (~a1 & a0)| (~a0 & a1);
endmodule

module testbench;
    reg a0,a1,a2,a3;
    wire b0,b1,b2,b3;
    initial begin
        $dumpfile("bcd_to_gray_code.vcd");
        $dumpvars(0,converter);
        $display("A3\tA2\tA1\tA0\t\tB3\tB2\tB1\tB0");
        $monitor("%b\t%b\t%b\t%b\t\t%b\t%b\t%b\t%b\t", a3,a2,a1,a0,b3,b2,b1,b0);
        #0 a0=1'b0; a1=1'b0;a2=1'b0;a3=1'b0;
        #2 a0=1'b1; a1=1'b0;a2=1'b0;a3=1'b0;
        #2 a0=1'b0; a1=1'b1;a2=1'b0;a3=1'b0;
        #2 a0=1'b1; a1=1'b1;a2=1'b0;a3=1'b0;
        #2 a0=1'b0; a1=1'b0;a2=1'b1;a3=1'b0;
        #2 a0=1'b1; a1=1'b0;a2=1'b1;a3=1'b0;
        #2 a0=1'b0; a1=1'b1;a2=1'b1;a3=1'b0;
        #2 a0=1'b1; a1=1'b1;a2=1'b1;a3=1'b0;
        #2 a0=1'b0; a1=1'b0;a2=1'b0;a3=1'b1; 
        #2 a0=1'b1; a1=1'b0;a2=1'b0;a3=1'b1; 
    end
    bcd_to_gray_code_df converter(a0,a1,a2,a3,b0,b1,b2,b3);
endmodule