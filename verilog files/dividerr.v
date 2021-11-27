// module mantissa(dividend,divisor,quotient);
// input [23:0] dividend,divisor;
// output [23:0] quotient;
// reg  [23:0]quotient;
// reg[23:0] div_reg;
// integer i;
// initial 
// begin
//     div_reg = dividend;
//     for(i=0;i<24;i=i+1) 
//         begin
//             if(div_reg>divisor)
//             begin
//                 #1
//                 quotient[i]=1'b1;
//                 div_reg=div_reg-divisor;
//                 #1
//                 div_reg=div_reg<<1;
//             end
//             else begin
//                 if(div_reg==divisor)begin
//                     quotient[i]=1'b1;
//                     div_reg=0;
//                 end
//                 else begin
//                     quotient[i]=1'b0;
//                     #1
//                     div_reg=div_reg<<1;
//                 end
//             end
//         end
// end
// endmodule

// module exponent(dividend,divisor,result);
// input [9:0]dividend,divisor;
// output [9:0] result;

// initial begin
//     result=dividend-divisor;
//     result=result+7'b1111111;
// end
// endmodule

module dividerr(a,b,quotient,over_under,clk);
input [31:0]a,b;
input clk;
output [31:0]quotient;
output over_under;
reg [31:0]quotient;
reg [9:0] a_exponent,b_exponent;
// wire [9:0] result_exponent;
reg[9:0] result;
wire x;
integer i;
integer denormalise_checker; 
reg over_under;
reg s1,s2;
xor (x,s1,s2);
// exponent X(a_exponent,b_exponent,result_exponent);
reg [23:0] a_mantissa,b_mantissa;
reg [23:0] result_mantissa;
// mantissa m(a_mantissa,b_mantissa,result_mantissa);
reg [2:0]state;
initial begin
    state =3'b000;
end
always @(posedge clk)
    begin
    case (state)
        3'b000:
            begin
                i = 0;
                denormalise_checker=0;
            state<=3'b001;           
            end
        3'b001:
            begin
                a_exponent[7:0]=a[30:23];
                b_exponent[7:0]=b[30:23];
                a_exponent[9:8] = 2'b00;
                b_exponent[9:8] = 2'b00;
                s1=a[31];
                s2=b[31];
                state <= 3'b010;
            end
        3'b010: 
            begin
                a_mantissa=a[22:0];
                if(a_exponent==8'b00000000)begin
                a_mantissa[23] = 1'b0;
                a_exponent=a_exponent+1;end
                else
                a_mantissa[23]=1'b1;
                b_mantissa=b[22:0]; 
                if(b_exponent==8'b00000000) begin
                b_mantissa[23]=1'b0;
                b_exponent=b_exponent+1;end
                else
                b_mantissa[23]=1'b1;
                state<=3'b011;
            end
        3'b011:
            begin
                result=(a_exponent-b_exponent)+7'b1111111;
                state <= 3'b100;
            end
        3'b100:
            begin
                    if(result>8'b11111110 || result<8'b00000001)begin
                        over_under=1'b1;
                        state<=3'b111;
                    end    
                    else
                      over_under=1'b0;
                    
                    if(a_mantissa>b_mantissa)
                    begin
                        result_mantissa[23-i]=1'b1;
                        a_mantissa=a_mantissa-b_mantissa;
                        a_mantissa=a_mantissa<<1;
                    end
                    else begin
                        if(a_mantissa==b_mantissa)begin
                            result_mantissa[23-i]=1'b1;
                            a_mantissa=0;
                        end
                        else begin
                            result_mantissa[23-i]=1'b0;
                            a_mantissa=a_mantissa<<1;
                        end
                    end
                    i =i+1;
                    if(i==24) begin 
                        state<=3'b101;
                    end
            end
        3'b101:
          if(result_mantissa[23]==1'b0) begin
              result_mantissa=result_mantissa<<1;
              result=result-1;
          end
          else 
            state=3'b110;
        3'b110:
        begin
            quotient[31]=x;
            quotient[30:23]=result[7:0];
            quotient[22:0]=result_mantissa[22:0];
            state<=3'b111;
            end
        3'b111:
            begin
            $display("Quotient: %b",quotient);
            state<=000;    
            end
        // default: $display("Default");
    endcase
end
// initial begin
//     #2
//     #2 
//      #4
//     quotient[31]=x;
//     if(result_exponent>8'b11111110 || result_exponent<8'b00000001)
//     error=1'b1;
//     else
//     error=1'b0;
//     quotient[30:23]=result_exponent[7:0];
    
//     #50
//     quotient[22:0]=result_mantissa[22:0];    
// end
endmodule

module testbench ();
reg [31:0] a,b;
wire [31:0] result;
wire error;
reg clk;
initial begin
    clk = 1'b0;
end
dividerr d(a,b,result,error,clk);
always begin
    #1 
    clk = ~clk;
end
initial begin
    $dumpfile("Divider.vcd");
    $dumpvars(0,d);
a=32'b01001000101100111010001101111010;
b=32'b00111010000101001001001111110110;
$monitor($time,"a=%b,b=%b,result=%b,error=%b",a,b,result,error);
#200 $finish;
end    
endmodule