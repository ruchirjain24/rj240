module checkInputs(InputA, InputB, AbyB, EXCEPTION);
	input [31:0] InputA;
	input [31:0] InputB;

	output [31:0] AbyB;
	output [1:0] EXCEPTION;

	// matissa parts of the inputs
	reg [22:0] mantissaA;
	reg [22:0] mantissaB;

	// exponent parts of the inputs
	reg [8:0] expA;
	reg [8:0] expB;

	// sign bits of the inputs
	reg signA;
	reg signB;

	// holds the value to output as exception
	reg [1:0] EXCEPTION;

	initial
	begin
		mantissaA = InputA[22:0];
		mantissaB = InputB[22:0];
		
		expA = InputA[30:23];
		expB = InputB[30:23];

		signA = InputA[31];
		signB = InputB[31];
	end

	// check if InputA or InputB is NaN
	if ((expA == 128 && mantissaA != 0) || (expB == 128 && mantissaB != 0))
	begin
		// exception 11 - invalid operands
		EXCEPTION = 2'b11;

		// quotient NaN
		putNaN qnan1(AbyB);
	end

	// check if InputA and InputB is inf
	else if (expA == 128 && expB == 128)
	begin
		// exception 11 - invalid operands
		EXCEPTION = 2'b11;

		// quotient NaN
		putNaN qnan2(AbyB);
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
			putNaN qnan3(AbyB);
		end

		// quotient inf
		putInf qinf1(signA, signB, AbyB);
	end

	// check if InputB is inf
	else if (expB == 128)
	begin
		// quotient zero
		qzero1(signA, signB, AbyB);
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
			putNaN qnan4(AbyB);
		end

		// quotient zero
		putZero qzero2(signA, signB, AbyB);
	end

	// check if InputB is zero
	else if ($signed(expB == -127) && mantissaB == 0)
	begin
		// exception 00 - division by zero attempted
		EXCEPTION = 2'b00;

		// quotient NaN
		putNaN qnan5(AbyB);
	end

	//>>> TEST FOR DENORMALIZED INPUTS <<<
endmodule

// module to put NaN into the quotient
module putNaN(AbyB);
	output [31:0] AbyB;

	reg [31:0] AbyB;

	initial
	begin
		AbyB[31] = 1;
		AbyB[30:23] = 255;
		AbyB[22] = 1;
		AbyB[21:0] = 0;
	end

endmodule

// module to put the appropriate infinite (+ or -)
// into the quotient
module putInf(signA, signB, AbyB);
	input signA;
	input signB;
	output [31:0] AbyB;

	reg [31:0] AbyB;

	initial
	begin 
		AbyB[31] = signA ^ signB;
		AbyB[30:23] = 255;
		AbyB[22:0] = 0;
	end

endmodule

// module to put zero in the quotient
module putZero(signA, signB, AbyB);
	input signA;
	input signB;
	output [31:0] AbyB;

	reg [31:0] AbyB;

	initial
	begin
		AbyB[31] = signA ^ signB;
		AbyB[30:23] = 0;
		AbyB[22:0] = 0;
	end

endmodule
