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
		EXCEPTION = 2'b00; // dummy value
	end

	end // initial block ends
	//>>> TEST FOR DENORMALIZED INPUTS <<<
endmodule

/*
// module to put NaN into the quotient
module putNaN(result);
	output [31:0] result;

	reg [31:0] result;

	initial
	begin
		result[31] = 1;
		result[30:23] = 255;
		result[22] = 1;
		result[21:0] = 0;
	end

endmodule

// module to put the appropriate infinite (+ or -)
// into the quotient
module putInf(signA, signB, result);
	input signA;
	input signB;
	output [31:0] result;

	reg [31:0] result;

	initial
	begin 
		result[31] = signA ^ signB;
		result[30:23] = 255;
		result[22:0] = 0;
	end

endmodule

// module to put zero in the quotient
module putZero(signA, signB, result);
	input signA;
	input signB;
	output [31:0] result;

	reg [31:0] result;

	initial
	begin
		result[31] = signA ^ signB;
		result[30:23] = 0;
		result[22:0] = 0;
	end

endmodule
*/
