module instfetch(
	input			clk,
	input			rstn,

	// 从ALU输入的信号				(Signals input from ALU)
	input [31:0]	i_PCPlus4_32,
	input [31:0]	i_JumpBranchAddr_32,

	// 从分支跳转控制单元输入的信号 (Signals input from JumpBranchControl)
	input			i_JumpBranch_1,

	// 输出到内存的信号				(Signals output to memory)
	// output[31:0]	o_NextPC_32,

	// 从内存输入的信号
	// input[31:0]		i_NextInst_32,
	
	// 输出到后续部分的信号
	output[31:0]	o_PC_32
	// output[31:0]	o_Inst_32
);

reg [31:0] PC;
// reg [31:0] Inst;

wire[31:0] NextPC;

assign NextPC	= {32{ i_JumpBranch_1 }}	& i_JumpBranchAddr_32
				| {32{~i_JumpBranch_1 }}	& i_PCPlus4_32			;


always @(posedge clk or negedge rstn) begin
	if(!rstn)begin
	   PC   <= 32'b0;
	   // Inst <= 32'b0;
	end else begin
	   PC	<= NextPC;
	   // Inst <= i_NextInst_32;
	end
end

// assign o_NextPC_32		= NextPC;
assign o_PC_32			= PC;
// assign o_Inst_32		= Inst;

endmodule
