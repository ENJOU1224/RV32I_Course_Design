module JumpBranchControl(
		input  [ 7:0]	i_JumpCode_8,
		input  [31:0]	i_CompareSrc1_32,
		input  [31:0]	i_CompareSrc2_32,
		output			o_Jump_1
);

	wire Jump,Equal,GreaterOrEqual;

	assign Jump		= |i_JumpCode_8[7:6]
					| Equal				& (i_JumpCode_8[5]|~i_JumpCode_8[4])
					| ~GreaterOrEqual	& |i_JumpCode_8[3:2]
					|  GreaterOrEqual	& |i_JumpCode_8[1:0]				;

	assign Equal	= & (i_CompareSrc1_32 & i_CompareSrc2_32);

	Comparator_32bit Comparator(
			.m		(i_CompareSrc1_32	),
			.n		(i_CompareSrc2_32	),
			.result	(GreaterOrEqual		)
	);

	assign o_Jump_1	= Jump;
endmodule
