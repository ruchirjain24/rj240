module checkInputs(InputA, InputB, result, EXCEPTION, valid, clk);
	input [31:0] InputA;
	input [31:0] InputB;

	output [31:0] result;
	output [1:0] EXCEPTION;
	output valid;
    input clk;
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

	always @(posedge clk)
	begin // initial block starts
		mantissaA = InputA[22:0];
		mantissaB = InputB[22:0];
		
		expA = InputA[30:23];
		expB = InputB[30:23];
        expA = expA-127;
        expB = expB-127;

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
		if ($signed(expB) == -127 && mantissaB == 0)
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
	else if ($signed(expB) == -127 && mantissaB == 0)
	begin
        EXCEPTION = 2'b00;
		// check if InputB is also zero
		if ($signed(expA) == -127 && mantissaA == 0)
		begin
			// exception 00 - division by zero attempted
			// quotient NaN
			result = valNaN;
		end
        else
            begin
                result = valZero;
            end
		// quotient zero
		
	end

	// check if InputB is zero
	else if ($signed(expB) == -127 && mantissaB == 0)
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
endmodule

module fpdiv(AbyB,DONE,EXCEPTION,InputA,InputB,CLOCK,RESET);
    input CLOCK,RESET ; // Active High Synchronous Reset
    input [31:0] InputA,InputB ;
    output reg[31:0]AbyB;
    output reg DONE ; // ‘0’ while calculating, ‘1’ when the result is ready
    output [1:0]EXCEPTION; // Used to output exceptions
    reg [1:0] EXCEPTION;
    wire [1:0] exception_wire;
    //main temporary registers to work on
    reg [31:0]a,b;
    reg [9:0] a_exponent,b_exponent;
    reg [24:0] a_mantissa,b_mantissa;
    reg s1,s2;
    reg clk_exception_circuit;
    reg [31:0]quotient;
    wire [31:0] special_result;
    reg over_under;
    
    // wire [9:0] result_exponent;
    reg[9:0] result;
    wire x,valid;
    // wire [1:0]EXCEPTION;
    integer i;
    integer denormalise_result_check;
    integer denormalise_checker; 
    
    xor (x,s1,s2);
    // exponent X(a_exponent,b_exponent,result_exponent);

    reg [23:0] result_mantissa;
    // mantissa m(a_mantissa,b_mantissa,result_mantissa);
    reg [3:0] state;
    checkInputs c(a, b, special_result, exception_wire, valid, clk_exception_circuit);
    always @(posedge CLOCK or posedge RESET) 
    begin
        case (state)
            4'b0000:   //getA&B
                begin
                    a <= InputA;
                    b <= InputB;
                    i <= 0;
                    denormalise_result_check <=0;
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
                    //otherwise just divide
                    clk_exception_circuit = 1'b0;
                    state<=4'b1001;
                end
            4'b1001:
                    begin
                     clk_exception_circuit = 1'b1; 
                    state<=4'b1010;     
                    end
            4'b1010:
                    if(valid == 1'b1)
                        state <= 4'b0011;
                    else
                        begin
                            quotient<=special_result;
                            EXCEPTION<= exception_wire;
                            state <= 4'b1000;    
                        end
            4'b0011:
                begin
                    a_mantissa[24] = 1'b0;
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
                    state <= 4'b0110;
                end
            4'b0101:    //normalise
                begin
                    if(result_mantissa[23]==1'b0) begin
                    result_mantissa=result_mantissa<<1;
                    result=result-1;
                end
                else 
                    state = 4'b0111; 
                end
               
                
            4'b0110:    //divide main and checking for underflow
                begin
                    if($signed(result)> 254 )
                        begin
                            EXCEPTION = 2'b10;
                            state <= 4'b1000;
                        end    
                    else if ($signed(result)< -22)
                        begin
                             EXCEPTION = 2'b01;
                            state <= 4'b1000;
                        end
                    
                    else if(a_mantissa>b_mantissa)
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
                        state<=4'b1011;
                    end
                end
            4'b1011:        //for denormalised numbers
            begin
                if($signed(result)< 1 && $signed(result)>-23)
                    begin
                        denormalise_result_check=1;
                        result<= result+1;
                        result_mantissa = result_mantissa>>1;
                    end
                else if(denormalise_result_check==1)
                    begin
                        result=result-1;
                        denormalise_result_check=0;
                        state<=4'b0111;
                    end
                else state<=4'b0101;
            end
            4'b0111:    //pack
                begin
                    quotient[31]=x;
                    quotient[30:23]=result[7:0];
                    quotient[22:0]=result_mantissa[22:0];
                    state <= 4'b1000;
                end
            4'b1000:    //final
                begin
                    // $display("\t\t  Quotient inside module: %b",quotient);
                    AbyB = quotient;
                    DONE = 1'b1;
                end 
        endcase

        if (RESET == 1)
        begin
            DONE = 1'b0;
            state <= 4'b0000;
        end
    end
endmodule
module tb_fp_div();
// Enter the ID No. and Name of all the Group Members Here Feel Free
// to Add/Delete based on the team size
    initial begin
        $display ("The Group Members are:");
        $display ("********************************************");
        $display ("2019A7PS0104P Tushar Garg");
        $display ("2019A7PS0067P Ruchir Jain");
        $display ("2019A7PS0127P Usneek Singh");
        $display ("2019A7PS1138P Yash Gupta");
        $display ("********************************************");
    end

// Edit this based on your design this is important information while
// doing the testing
// Enter the correct information here
    initial begin
        $display ("A few things about our design:");
        $display ("********************************************");
        $display ("It works on the Positive edge of the CLOCK signal");
        $display ("Will take 80 (max) CLOCK cycles to complete the execution");
        $display ("We haven't used the guard bits");
        $display ("Sir please provide a positive edge on RESET to change the inputs to the divider");
        $display ("Our divider waits at the done state if no RESET is provided");
        $display ("The clock cycle is of 4 units");
        $display ("********************************************");
    end

    reg [31:0] a,b;
    wire [31:0] result;
    reg RESET;
    wire DONE;
    wire [1:0] EXCEPTION;
    reg CLOCK;

    initial begin
        CLOCK = 1'b0;
        #2 
        a = 32'b00000000001100010000000000101011;
        b = 32'b11000001000101100110011001100110;
        #1 RESET = 1'b0;
        #1 RESET = 1'b1;
        #1 RESET = 1'b0;
    end

    fpdiv d(result,DONE,EXCEPTION,a,b,CLOCK,RESET);
    always begin
        #2 CLOCK = ~CLOCK;
    end
    initial begin
        $dumpfile("Divider.vcd");
        $dumpvars(0,d);
        $monitor($time," a=%b, b=%b, result=%b EXCPTN=%b DONE=%b",a,b,result,EXCEPTION,DONE);
        #5500 $finish;
    end
endmodule