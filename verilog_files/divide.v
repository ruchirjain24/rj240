// module fpdiv(AbyB,DONE,EXCEPTION,InputA,InputB,CLOCK,RESET);
//     input CLOCK,RESET ; // Active High Synchronous Reset
//     input [31:0] InputA,InputB ;
//     output [31:0]AbyB;
//     output DONE ; // ‘0’ while calculating, ‘1’ when the result is ready
//     output [1:0]Exception; // Used to output exceptions

//     reg       [31:0] a, b, z;
//     reg       [23:0] a_m, b_m, z_m;
//     reg       [9:0] a_e, b_e, z_e;
//     reg       a_s, b_s, z_s;
//     reg       guard, round_bit, sticky;
//     reg       [50:0] quotient, divisor, dividend, remainder;
//     reg       [5:0] count;
//     reg       [3:0] state;
//     always @(posedge CLOCK) 
//     begin
//         case (state)
//             4'b0000:   //getA&B
//                 begin
//                     a <= InputA
//                     b <= InputB
//                     state <= 4'b0001;
//                 end
//             4'b0001:
//                 begin
//                     a_m <= a[22 : 0];
//                     b_m <= b[22 : 0];
//                     a_e <= a[30 : 23] - 127;
//                     b_e <= b[30 : 23] - 127;
//                     a_s <= a[31];
//                     b_s <= b[31];
//                     state <= 4'b0010;
//                 end
//             4'b0010:
//                 begin
//                     //exceptions and put_z if exception comes

//                     //otherwise just divide 
//                     state <= 4'b0011
//                 end
//             4'b0011:
//                 begin
//                     //divide

//                     state 
//                 end
//             default: 
//         endcase
//         if (RESET == 1)
//         begin
//             state <= 4'b0000;
//         end
//     end
// endmodule
module checkInputs(InputA, InputB, result, EXCEPTION, valid);
	input [31:0] InputA;
	input [31:0] InputB;

	output [31:0] result;
	output [1:0] EXCEPTION;
	output valid;

	// matissa parts of the inputs
	reg [22:0] mantissaA;
	reg [22:0] mantissaB;

	// exponent parts of the inputs
	reg [8:0] expA;
	reg [8:0] expB;

	// sign bits of the inputs
	reg signA;
	reg signB;

	// a NaN value
	reg [31:0] valNaN;

	// an Inf value
	reg [31:0] valInf;

	// a Zero value
	reg [31:0] valZero;

	// holds the value to output as exception
	reg [1:0] EXCEPTION;
	
	// quotient for invalid inputs
	reg [31:0] result;

	// inputs valid or not - 1 for valid
	reg valid;

	initial
	begin // initial block starts
		mantissaA = InputA[22:0];
		mantissaB = InputB[22:0];
		
		expA = InputA[30:23];
		expB = InputB[30:23];

		signA = InputA[31];
		signB = InputB[31];

		valNaN[31] = 1;
		valNaN[30:23] = 255;
		valNaN[22] = 1;
		valNaN[21:0] = 0;

		valInf[31] = InputA[31] ^ InputB[31];
		valInf[30:23] = 255;
		valInf[22:0] = 0;

		valZero[31] = InputA[31] ^ InputB[31];
		valZero[30:23] = 0;
		valZero[22:0] = 0;
		
		valid = 1'b0;

	#1
	// check if InputA or InputB is NaN
	if ((expA == 128 && mantissaA != 0) || (expB == 128 && mantissaB != 0))
	begin
		// exception 11 - invalid operands
		EXCEPTION = 2'b11;

		// quotient NaN
		result = valNaN;
	end

	// check if InputA and InputB is inf
	else if (expA == 128 && expB == 128)
	begin
		// exception 11 - invalid operands
		EXCEPTION = 2'b11;

		// quotient NaN
		result = valNaN;
	end

	// check if InputA is inf
	else if (expA == 128)
	begin
		// check if InputB is zero
		if ($signed(expB == -127) && mantissaB == 0)
		begin
			// exception 00 - division by zero attempted
			EXCEPTION = 2'b00;

			// quotient NaN
			result = valNaN;
		end

		// quotient inf
		result = valInf;
	end

	// check if InputB is inf
	else if (expB == 128)
	begin
		// quotient zero
		result = valZero;
	end

	// check if InputA is zero
	else if ($signed(expA == -127) && mantissaA == 0)
	begin
		// check if InputB is also zero
		if ($signed(expB == -127) && mantissaB == 0)
		begin
			// exception 00 - division by zero attempted
			EXCEPTION = 2'b00;

			// quotient NaN
			result = valNaN;
		end

		// quotient zero
		result = valZero;
	end

	// check if InputB is zero
	else if ($signed(expB == -127) && mantissaB == 0)
	begin
		// exception 00 - division by zero attempted
		EXCEPTION = 2'b00;

		// quotient NaN
		result = valNaN;
	end

	// valid inputs
	else
	begin
		valid = 1'b1;
		result = 0; // dummy value
		// EXCEPTION = 2'b00; // dummy value
	end

	end // initial block ends
	//>>> TEST FOR DENORMALIZED INPUTS <<<
endmodule

module fpdiv(AbyB,DONE,EXCEPTION,InputA,InputB,CLOCK,RESET);
    input CLOCK,RESET ; // Active High Synchronous Reset
    input [31:0] InputA,InputB ;
    output reg[31:0]AbyB;
    output reg DONE ; // ‘0’ while calculating, ‘1’ when the result is ready
    output [1:0]EXCEPTION; // Used to output exceptions

    //main temporary registers to work on
    reg [31:0]a,b;
    reg [9:0] a_exponent,b_exponent;
    reg [23:0] a_mantissa,b_mantissa;
    reg s1,s2;

    reg [31:0]quotient;
    reg over_under;
    
    // wire [9:0] result_exponent;
    reg[9:0] result;
    wire x,valid;
    // wire [1:0]EXCEPTION;
    integer i;
    integer denormalise_checker; 
    
    xor (x,s1,s2);
    // exponent X(a_exponent,b_exponent,result_exponent);

    reg [23:0] result_mantissa;
    // mantissa m(a_mantissa,b_mantissa,result_mantissa);
    reg [3:0] state;

    always @(posedge CLOCK) 
    begin
        case (state)
            4'b0000:   //getA&B
                begin
                    a <= InputA;
                    b <= InputB;
                    i <= 0;
                    denormalise_checker <= 0;
                    state <= 4'b0001;
                end
            4'b0001:    //Unpack
                begin
                    a_exponent[7:0] <= a[30:23];
                    b_exponent[7:0] <= b[30:23];
                    a_exponent[9:8] <= 2'b00;
                    b_exponent[9:8] <= 2'b00;
                    s1 <= a[31];
                    s2 <= b[31];
                    state <= 4'b0010;
                end
            4'b0010:
                begin
                    //exceptions and put_z if exception comes
                    checkInputs c(a, b, quotient, EXCEPTION, valid);
                    //otherwise just divide 
                    if(valid == 1'b1)
                        state <= 4'b0011;
                    else
                        begin
                            state <= 4'b1000;    
                        end
                end
            4'b0011:
                begin
                    a_mantissa=a[22:0];
                    if(a_exponent==8'b00000000)
                        begin
                            a_mantissa[23] = 1'b0;
                            a_exponent=a_exponent+1;
                        end
                    else
                        a_mantissa[23]=1'b1;

                    b_mantissa=b[22:0]; 
                    if(b_exponent==8'b00000000) 
                        begin
                            b_mantissa[23]=1'b0;
                            b_exponent=b_exponent+1;
                        end
                    else
                        b_mantissa[23]=1'b1;

                    state<=4'b0100; 
                end
            4'b0100:    //exponent subtract
                begin
                    result=(a_exponent-b_exponent)+7'b1111111;
                    state <= 4'b0101;
                end
            4'b0101:    //divide main and checking for underflow
                begin
                    if(result>8'b11111110 || result<8'b00000001)
                        begin
                            over_under=1'b1;
                            state <= 4'b1000;
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
                        state<=4'b0110;
                    end
                end
            4'b0110:    //normalise
                if(result_mantissa[23]==1'b0) begin
                    result_mantissa=result_mantissa<<1;
                    result=result-1;
                end
                else 
                    state = 4'b0111;
            4'b0111:    //pack
                begin
                    quotient[31]=x;
                    quotient[30:23]=result[7:0];
                    quotient[22:0]=result_mantissa[22:0];
                    state <= 4'b1000;
                end
            4'b1000:    //final putz
                begin
                    $display("\t\t  Quotient inside module: %b",quotient);
                    AbyB = quotient;
                    state = 4'b0000;
                    DONE = 1'b1;
                end 
        endcase

        if (RESET == 1)
        begin
            state <= 4'b0000;
        end
    end
endmodule


module divtest;
    reg [31:0] a,b;
    wire [31:0] result;
    reg RESET;
    wire DONE;
    wire [1:0] EXCEPTION;
    reg CLOCK;
    initial begin
        CLOCK = 1'b0;
        RESET = 1'b1;
        a=32'b01001000101100111010001101111010;
        b=32'b00111010000101001001001111110110;
    end

    fpdiv d(result,DONE,EXCEPTION,a,b,CLOCK,RESET);
    // dividerr d(a,b,result,error,CLOCK);
    always begin
        #2 
        CLOCK = ~CLOCK;
    end
    initial begin
        $dumpfile("Divider.vcd");
        $dumpvars(0,d);
        $monitor($time,"a=%b, b=%b, result=%b",a,b,result,DONE);
        #3 RESET=1'b0;
        #200 $finish;
    end    
endmodule