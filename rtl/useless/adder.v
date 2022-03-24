module m_adder (
		input [63:0] i_adderOperand1_64,
		input [63:0] i_adderOperand2_64,
		input 		 i_cIn_1,
		output[63:0] o_adderSum_64,
		output		 o_cOut_1
);
	wire [7:0][7:0] w_0inTempSum_8;
	wire [7:0][7:0] w_1inTempSum_8;
	wire [7:0][7:0] w_tempSum_8;
	wire [7:0] 		w_0inCIn_8;
	wire [7:0] 		w_1inCIn_8;
	wire [7:0] 		w_cIn_8;

	genvar i;
	generate
			for(i=0; i<8;i=i+1)begin
					m_adder8 m_in0Adder8(
							.i_cIn_1 			(1'b0 							),
							.i_adderOperand1_8 	(i_adderOperand1_64[7+8*i:8*i] 	),
							.i_adderOperand2_8 	(i_adderOperand2_64[7+8*i:8*i] 	),
							.o_cOut_1      		(w_0inCIn_8[i] 					),
							.o_adderSum_8 		(w_0inTempSum_8[i] 				)
					);
					m_adder8 m_in1Adder8(
							.i_cIn_1 			(1'b1 							),
							.i_adderOperand1_8 	(i_adderOperand1_64[7+8*i:8*i] 	),
							.i_adderOperand2_8 	(i_adderOperand2_64[7+8*i:8*i] 	),
							.o_cOut_1      		(w_1inCIn_8[i] 					),
							.o_adderSum_8      	(w_1inTempSum_8[i] 				)
					);
			end
	endgenerate

	integer j,k;

	always@(*)begin
			for(j=0; j<8;j=j+1)begin
				if(j==1)begin
					w_cIn_8[j] 		 = i_cIn_1;
				end else begin
					w_cIn_8[j] 		 = w_cIn_8[j-1] ? w_1inCIn_8[j] : w_0inCIn_8[j];
				end
				k = 8*j;
				w_tempSum_8[j] = w_cIn_8[j] ? w_1inTempSum_8[j] : w_0inTempSum_8[j];
			end
	end

	assign o_adderSum_64[ 7: 0]	= w_tempSum_8[0];
	assign o_adderSum_64[15: 8]	= w_tempSum_8[1];
	assign o_adderSum_64[23:16]	= w_tempSum_8[2];
	assign o_adderSum_64[31:24]	= w_tempSum_8[3];
	assign o_adderSum_64[39:32]	= w_tempSum_8[4];
	assign o_adderSum_64[47:40]	= w_tempSum_8[5];
	assign o_adderSum_64[55:48]	= w_tempSum_8[6];
	assign o_adderSum_64[63:56]	= w_tempSum_8[7];

	assign o_cOut_1 = w_cIn_8[7];


endmodule
