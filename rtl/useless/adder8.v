module m_adder8(
		input i_adderOperand1_8,
		input i_adderOperand2_8,
		input i_cIn_1,
		output o_adderSum_8,
		output o_cOut_1
);
	assign {o_cOut_1,o_adderSum_8} 	= i_adderOperand1_8 +i_adderOperand2_8 + i_cIn_1;
endmodule
