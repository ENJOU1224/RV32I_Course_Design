module instfetch(
	// 从ALU输入的信号				(Signals input from ALU)
	input [31:0]	i_JumpBranchAddr_32,
	input					i_JumpBranchInALU_1,

	// 从级间寄存器输入的信号	(Signals input from IFtoDE_REG)
	input [31:0]  i_PC_32,

	// 从分支跳转控制单元输入的信号 (Signals input from JumpBranchControl)
	input			i_JumpBranchInDE_1,

	// 输出到内存的信号				(Signals output to memory)
	 output[31:0]	o_NextPC_32,

	// 输出到后续的信号
	output [31:0] o_PCPlus4_32,

	input					i_WaitLoad_1
);


wire[31:0] NextPC;
wire[31:0] PCPlus4;

wire JumpBranch = i_JumpBranchInDE_1 & i_JumpBranchInALU_1 & ~i_WaitLoad_1;

wire Wait = i_JumpBranchInDE_1 & ~i_JumpBranchInALU_1 | i_WaitLoad_1;

wire GoOn = ~i_JumpBranchInDE_1 & ~i_WaitLoad_1;

assign PCPlus4 = i_PC_32 + 4;

assign NextPC	= {32{ JumpBranch }}	& i_JumpBranchAddr_32
							| {32{ Wait				}}	& i_PC_32			
							| {32{ GoOn				}}	& PCPlus4			;

assign o_NextPC_32		= NextPC;
assign o_PCPlus4_32		= PCPlus4;

endmodule
