module added(A,B,cin,sum,cout);
    input [31:0] A,B;
    output [31:0] sum;
    input cin;
    output cout;
    assign {cout,sum} = A+B+cin;
endmodule

module test_Added;
    reg [31:0] A,B;
    reg cin;
    wire cout;
    wire [31:0] sum;
    added aaa(A,B,cin,sum,cout);
    initial begin
        A = 32'd0;
        B = 32'd11;
        cin = 1'b1; 
    end
    initial begin
        $monitor($time," A = %d \t B = %d \t cin = %b \t cout = %b \t sum = %d\n",A,B,cin,cout,sum);
        #5 cin=1'b0;
        #5 B=32'hFFFFFFFF;
        A=32'd1;
        #5 B=32'hCCCCAAAA;
    end
endmodule 