module JumpBranchControl(
		input			i_UnsignedCMP_1,
		input  [ 7:0]	i_JumpCode_8,
		input  [31:0]	i_CompareSrc1_32,
		input  [31:0]	i_CompareSrc2_32,
		output			o_JumpBranch_1
);

	wire Jump,Equal,GreaterOrEqual,ComparatorResult,UnsignedOrSameSign;

	assign Jump		= |i_JumpCode_8[7:6]																// 无条件跳转
									| Equal						& i_JumpCode_8[5]								// beq
									|~Equal						& i_JumpCode_8[4]								// bne
									| ~GreaterOrEqual	& |i_JumpCode_8[3:2]						// blt
									|  GreaterOrEqual	& |i_JumpCode_8[1:0]				;		// bge

	assign Equal				= ~| (i_CompareSrc1_32 ^ i_CompareSrc2_32);

	Comparator_32bit Comparator(
			.m				(i_CompareSrc1_32	),
			.n				(i_CompareSrc2_32	),
			.equal		( 1'b1						),
			.result		(ComparatorResult	)
	);

	assign UnsignedOrSameSign		= i_UnsignedCMP_1|~(i_CompareSrc1_32[31]^i_CompareSrc2_32[31]);
	
	assign GreaterOrEqual 	=	 UnsignedOrSameSign & ComparatorResult
													| ~UnsignedOrSameSign & i_CompareSrc2_32[31];

	assign o_JumpBranch_1	= Jump;
endmodule
