module JumpBranchControl(
		input			i_UnsignedCMP_1,
		input  [ 7:0]	i_JumpCode_8,
		input  [31:0]	i_CompareSrc1_32,
		input  [31:0]	i_CompareSrc2_32,
		output			o_JumpBranch_1
);

	wire Jump,Equal,GreaterOrEqual;
	wire [31:0]		CompareSrc1;
	wire [31:0]		CompareSrc2;

	assign Jump		= |i_JumpCode_8[7:6]
					| Equal				& (i_JumpCode_8[5]|~i_JumpCode_8[4])
					| ~GreaterOrEqual	& |i_JumpCode_8[3:2]
					|  GreaterOrEqual	& |i_JumpCode_8[1:0]				;

	assign Equal	= & (i_CompareSrc1_32 & i_CompareSrc2_32);

	assign CompareSrc1	= {32{ i_UnsignedCMP_1|~i_CompareSrc1_32[31]}}	&  i_CompareSrc1_32
						| {32{~i_UnsignedCMP_1& i_CompareSrc1_32[31]}}	& ~i_CompareSrc1_32+1 ;

	assign CompareSrc2	= {32{ i_UnsignedCMP_1|~i_CompareSrc2_32[31]}}	&  i_CompareSrc2_32
						| {32{~i_UnsignedCMP_1& i_CompareSrc2_32[31]}}	& ~i_CompareSrc2_32+1 ;

	Comparator_32bit Comparator(
			.m		(CompareSrc1		),
			.n		(CompareSrc2		),
			.equal	( 1'b1				),
			.result	(GreaterOrEqual		)
	);

	assign o_JumpBranch_1	= Jump;
endmodule
