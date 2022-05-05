
/*
    -- ============================================================================
    -- FILE NAME	: alu.v
    -- DESCRIPTION	: 算术逻辑单元，整合了部分NextPC生成
    -- ----------------------------------------------------------------------------
    -- Revision	Date		Coding_by	 Comment
    -- 1.0.0	2022/03/24  enjou		 初版 
    -- ============================================================================
*/
module alu(
	input  [31:0]	PC,

	// 来自DECODE部分的信号					(Signals from DECODE Part)	
	input  [11:0]	i_ALUControl_12,
	input  [31:0]	i_ALUOperand1_32,
	input  [31:0]	i_ALUOperand2_32,

	// 输出到NextPC部分						(Output to NextPC Part)	
	output [31:0]	o_JumpBranchAddr_32,
	output [31:0]	o_PCPlus4_32,

	// 输出到Memory部分						(Output to Memory Part)
	output [31:0]	o_ALUResult_32
);

//--------------------控制信号拆分(Control Signal Splitting)--------------------//
	wire	ADD , PC4	, SUB	, SLT	,
			SLTU, AND	, OR	, XOR	,
			SLL	, SRL	, SRA	, LUI	;

	assign {
			ADD ,
			PC4 ,
			SUB ,
			SLT ,
			SLTU,
			AND ,
			OR  ,
			XOR ,
			SLL ,
			SRL ,
			SRA ,
			LUI
				} = i_ALUControl_12;

//--------------------ALU运算(AlU Operation)--------------------//
	
	// 加减法
	wire [31:0]	AddSubResult;
	wire [31:0]	AdderOperand2;	

	assign AdderOperand2	= {32{ SUB}} & ~i_ALUOperand2_32
							| {32{~SUB}} &  i_ALUOperand2_32;
	
	// assign AddSubResult		= i_ALUOperand1_32 + AdderOperand2 +SUB;
	 Adder Adder(
	         .i_adderOperand1_32		(i_ALUOperand1_32	),
	         .i_adderOperand2_32		(AdderOperand2		),
	         .i_cIn_1			        (SUB				),
	         .o_adderSum_32			    (AddSubResult		),
	         .o_cOut_1			        (			        )
	 );

	// PC+4
	wire [31:0]	PC4Result;

	assign PC4Result	= PC + 4;

	// SLT&SLTU
	wire [31:0] SLTResult;
	wire [31:0] SLTUResult;
	wire [31:0] SLTOperand1;
	wire [31:0] SLTOperand2;
	wire		Operand1Small;
	wire		Operand2Small;

	assign SLTOperand1	= {32{ i_ALUOperand1_32[31]& SLT}}	& ~i_ALUOperand1_32 +1 
						| {32{~i_ALUOperand1_32[31]|~SLT}}	& i_ALUOperand1_32;

	assign SLTOperand2	= {32{ i_ALUOperand2_32[31]& SLT}}	& ~i_ALUOperand2_32 +1 
						| {32{~i_ALUOperand2_32[31]|~SLT}}	& i_ALUOperand2_32;

	Comparator_32bit Comparator1(
		.m			(SLTOperand2	),
		.n			(SLTOperand1	),
		.equal		(1'b0			),
		.result		(Operand1Small	)
	);

	Comparator_32bit Comparator2(
		.m			(SLTOperand1	),
		.n			(SLTOperand2	),
		.equal		( 1'b0			),
		.result		(Operand2Small	)
	);
	assign SLTResult	= {31'b0, ( i_ALUOperand1_32[31]&~i_ALUOperand2_32[31])
								| ( i_ALUOperand1_32[31]& i_ALUOperand2_32[31]&Operand2Small)
								| (~i_ALUOperand1_32[31]&~i_ALUOperand2_32[31]&Operand1Small)};
	
	assign SLTUResult	= {31'b0, Operand1Small};
	// AND
	wire [31:0] ANDResult;

	assign ANDResult	= i_ALUOperand1_32 & i_ALUOperand2_32;

	// OR
	wire [31:0]	ORResult;

	assign ORResult		= i_ALUOperand1_32 | i_ALUOperand2_32;

	// XOR
	wire [31:0] XORResult;

	assign XORResult	= i_ALUOperand1_32 ^ i_ALUOperand2_32;

	// SLL
	wire [31:0] SLLResult;

	assign SLLResult	= i_ALUOperand1_32 << i_ALUOperand2_32[4:0];

	// SRL
	wire [31:0] SRLResult;

	assign SRLResult	= i_ALUOperand1_32 >> i_ALUOperand2_32[4:0];

	// SRA
	wire [31:0] SRAResult;

	assign SRAResult	= ($signed(i_ALUOperand1_32)) >>> i_ALUOperand2_32[4:0];

	// LUI
	wire [31:0] LUIResult;

	assign LUIResult	= i_ALUOperand2_32;
	
//--------------------输出信号生成(Output Signals Generation)--------------------//

	assign o_ALUResult_32	= {32{ADD }}	& AddSubResult
												| {32{SUB }}	& AddSubResult
												| {32{PC4 }}	& PC4Result
												| {32{SLT }}	& SLTResult
												| {32{SLTU}}	& SLTUResult
												| {32{AND }}	& ANDResult
												| {32{OR  }}	& ORResult
												| {32{XOR }}	& XORResult
												| {32{SLL }}	& SLLResult
												| {32{SRL }}	& SRLResult
												| {32{SRA }}	& SRAResult
												| {32{LUI }}	& LUIResult;

	assign o_JumpBranchAddr_32	= AddSubResult;

	assign o_PCPlus4_32			= PC4Result;
endmodule
