module m_adder4(
		input			i_cIn_1,
		input [3:0] 	i_adderOperand1_4,
		input [3:0] 	i_adderOperand2_4, 
		output[3:0] 	o_adderResult_4,
		output 			o_cOut_1
);
	
	assign {o_cOut_1,o_adderResult_4} 	= i_adderOperand1_4 +i_adderOperand2_4+i_cIn_1;

endmodule
