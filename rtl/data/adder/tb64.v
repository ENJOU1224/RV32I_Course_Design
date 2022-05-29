module tb(

);
reg cin;
wire cout;
wire good;
reg c;
reg [63:0] Operand1;
reg [63:0] Operand2;
wire[63:0] Result;
reg [63:0] sum;

m_adder m_adder(
		.i_cIn_1							(cin					),
		.i_adderOperand1_64		(Operand1			),
		.i_adderOperand2_64		(Operand2			),
		.o_adderSum_64				(Result				),
		.o_cOut_1							(cout					)
);

initial begin
	cin		= 0;
	Operand1= 0;
	Operand2= 0;
	repeat(100)begin
		#10
		cin		= {$random}%2;
		Operand1= {{$random}%32'hFFFFFFFF,{$random}%32'hFFFFFFFF};
		Operand2= {{$random}%32'hFFFFFFFF,{$random}%32'hFFFFFFFF};
		{c,sum}	= Operand1 + Operand2 + cin;
		if(!good) $finish;
	end
	$finish;
end
	assign good = Result == sum && c == cout; 
endmodule
