module m_adder(
	input [31:0] i_adderOperand1_32,
	input [31:0] i_adderOperand2_32,
	input		 i_cIn_1,
	output[31:0] o_adderSum_32,
	output		 o_cOut_1
	);

	wire [63:0]
genvar i;
generate
	for(i=0; i<64; i=i+1)begin
		m_pgGen u_pgGen(
			.i_a( i_adderOperand1_32[i]),
			.i_b( i_adderOperand2_32[i]),
			.o_g(  )
endmodule
