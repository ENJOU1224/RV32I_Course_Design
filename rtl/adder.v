module m_adder (
		input [63:0] i_adderOperand1_64,
		input [63:0] i_adderOperand2_64,
		input 		 i_cIn_1,
		output[63:0] o_adderSum_64,
		output		 o_cOut_1
);
	wire [15:0][3:0] w_0inTempSum_4;
	wire [15:0][3:0] w_1inTempSum_4;
	reg  [15:0][3:0] w_tempSum_4;
	reg  [15:0]		w_0inCIn_16;
	reg  [15:0]		w_1inCIn_16;
	reg  [15:0]		w_cIn_16;

	genvar i;
	generate
			for(i=0; i<16;i=i+1)begin
					m_adder4 m_in0Adder4(
							.i_cIn_1 			(1'b0 							),
							.i_adderOperand1_8 	(i_adderOperand1_64[7+8*i:8*i] 	),
							.i_adderOperand2_8 	(i_adderOperand2_64[7+8*i:8*i] 	),
							.o_cOut_1      		(w_0inCIn_16[i] 				),
							.o_adderSum_8 		(w_0inTempSum_4[i] 				)
					);
					m_adder4 m_in1Adder4(
							.i_cIn_1 			(1'b1 							),
							.i_adderOperand1_8 	(i_adderOperand1_64[7+8*i:8*i] 	),
							.i_adderOperand2_8 	(i_adderOperand2_64[7+8*i:8*i] 	),
							.o_cOut_1      		(w_1inCIn_16[i] 				),
							.o_adderSum_8      	(w_1inTempSum_4[i] 				)
					);
			end
	endgenerate

	integer j;

	always@(*)begin
			for(j=0; j<16;j=j+1)begin
				if(j==0)begin
					w_cIn_16[j] 		 = i_cIn_1;
				end else begin
					w_cIn_16[j] 		 = w_cIn_16[j-1] ? w_1inCIn_16[j] : w_0inCIn_16[j];
				end
				w_tempSum_4[j]			= w_cIn_16[j] ? w_1inTempSum_4[j] : w_0inTempSum_4[j];
			end
	end

	genvar k;
	generate
		for (k = 0; k < 16; k=k+1) begin
			assign	o_adderSum_64[3+k:k]= w_tempSum_4[j];
		end
	endgenerate
	assign o_cOut_1 = w_cIn_16[15];


endmodule
