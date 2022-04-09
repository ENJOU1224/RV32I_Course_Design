module tb(

);
reg cin;
wire cout;
wire good;
reg c;
reg [3:0] Operand1;
reg [3:0] Operand2;
wire[3:0] Result;
reg [3:0] sum;

m_adder4 adder4(
	.i_cIn_1			(cin		),
	.i_adderOperand1_4	(Operand1	),
	.i_adderOperand2_4	(Operand2	),
	.o_adderResult_4	(Result		),
	.o_cOut_1			(cout		)
);

initial begin
	cin		= 0;
	Operand1= 0;
	Operand2= 0;
	repeat(100)begin
		#10
		cin		= {$random}%2;
		Operand1= {$random}%16;
		Operand2= {$random}%16;
		{c,sum}	= Operand1 + Operand2 + cin;
	end
	$finish;
end
	assign good = Result == sum && c == cout; 
endmodule
