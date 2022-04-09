module m_adder4(
		input			i_cIn_1,
		input [3:0] 	i_adderOperand1_4,
		input [3:0] 	i_adderOperand2_4, 
		output[3:0] 	o_adderResult_4,
		output 			o_cOut_1
);
	
	wire [3:0] p;
	wire [3:0] g;
	wire [3:0] c;
	genvar i;
	generate
		for (i = 0; i < 4; i=i+1) begin :pgGen
			pgGen pgGen(
				.a		(i_adderOperand1_4[i]	),
				.b		(i_adderOperand2_4[i]	),
				.p		(p[i]					),
				.g		(g[i]					)
			);
		end
	endgenerate

	CarryGen CarryGen(
		.p		(p			),
		.g		(g			),
		.cin	(i_cIn_1	),
		.c		(c			),
		.cout	(o_cOut_1	)
	);

	generate
		for (i = 0; i < 4; i=i+1) begin
			assign o_adderResult_4[i]	= p[i] ^ c[i];	
		end
	endgenerate

endmodule
