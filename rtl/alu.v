
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
	input  [31:0]	Inst,

	// 来自DECODE部分的信号					(Signals from DECODE Part)	
	input  [11:0]	i_ALUControl_12,
	input  [31:0]	i_ALUOperand1_32,
	input  [31:0]	i_ALUOperand2_32,

	// 输出到NextPC部分						(Output to NextPC Part)	
	output [31:0]	o_JumpBranchAddr_32,

	// 输出到Memory部分						(Output to Memory Part)
	output [31:0]	o_ALUResult_32
);

	//--------------------控制信号拆分(Control Signal Splitting)--------------------//
endmodule
