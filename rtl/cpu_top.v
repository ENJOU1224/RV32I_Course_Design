module cpu_top(
	input clk,
	input rstn
);
wire [31:0]		PCPlus4;
wire [31:0]		JumpBranchAddr;
wire			JumpBranch;
wire [31:0]		PC;
wire [31:0]		Inst;

instfetch instfetch(
		.clk				(clk			),			// 时钟信号
		.rstn				(rstn			),			// 复位信号
		.i_PCPlus4_32		(PCPlus4		),			// 当前指令PC+4的值
		.i_JumpBranchAddr_32(JumpBranchAddr ),			// 分支跳转的目的地址
		.i_JumpBranch_1		(JumpBranch		),			// 分支跳转的标志
		.o_PC_32			(PC				)			// 当前指令PC
);
dist_mem_gen_1 IRom (
  .a(PC[11:2]),      // input wire [9 : 0] a
  .spo(Inst)  // output wire [31 : 0] spo
);
wire [ 4:0] GRFReadAddr1;
wire [ 4:0] GRFReadAddr2;
wire [ 4:0] GRFWriteAddr;
wire [31:0] GRFReadData1;
wire [31:0] GRFReadData2;
wire		GRFWen;
wire [11:0] ALUControl;
wire [31:0] ALUOperand1;
wire [31:0] ALUOperand2;
wire		Load;
wire		Store;
wire		LoadUnsigned;
wire [ 1:0] LoadStoreWidth;
wire [31:0] StoreData;
wire [ 7:0] JumpBranchType;
wire [31:0] CompareSrc1;
wire [31:0] CompareSrc2;
wire		UnsignedCMP;

decode decode(
		.PC					(PC				),				// 当前指令PC
		.Inst				(Inst			),				// 当前指令
		.o_GRFReadAddr1_5	(GRFReadAddr1	),				// 通用寄存器读接口1的地址
		.o_GRFReadAddr2_5	(GRFReadAddr2	),				// 通用寄存器读接口2的地址
		.i_GRFReadData1_32	(GRFReadData1	),				// 通用寄存器读接口1的数据
		.i_GRFReadData2_32	(GRFReadData2	),				// 通用寄存器读接口2的数据
		.o_GRFWriteAddr_5	(GRFWriteAddr	),				// 通用寄存器写接口地址
		.o_GRFWen_1			(GRFWen			),				// 通用寄存器写使能信号
		.o_ALUControl_12	(ALUControl		),				// ALU控制信号
		.o_ALUOperand1_32	(ALUOperand1	),				// ALU操作数1
		.o_ALUOperand2_32	(ALUOperand2	),				// ALU操作数2
		.o_Load_1			(Load			),				// 读指令信号
		.o_Store_1			(Store			),				// 写指令信号
		.o_LoadUnsigned_1	(LoadUnsigned	),				// 无符号拓展的读指令信号
		.o_LoadStoreWidth_2 (LoadStoreWidth ),				// 读写宽度
		.o_StoreData_32		(StoreData		),				// 写指令的数据
		.o_JumpBranchType_8 (JumpBranchType ),				// 分支跳转类型
		.o_CompareSrc1_32	(CompareSrc1	),				// 分支类型比较操作数1
		.o_CompareSrc2_32	(CompareSrc2	),				// 分支类型比较操作数2
		.o_UnsignedCMP_1	(UnsignedCMP	)				// 无符号比较
);

wire [31:0] ALUResult;
alu alu(
		.PC					(PC				),				// 当前指令PC
		.i_ALUControl_12	(ALUControl		),				// ALU控制信号
		.i_ALUOperand1_32	(ALUOperand1	),				// ALU操作数1 
		.i_ALUOperand2_32	(ALUOperand2	),				// ALU操作数2
		.o_JumpBranchAddr_32(JumpBranchAddr	),				// 分支跳转的目的地址
		.o_PCPlus4_32		(PCPlus4		),				// PC+4的值 
		.o_ALUResult_32		(ALUResult		)				// ALU计算结果
);

JumpBranchControl JumpBranchControl(
		.i_UnsignedCMP_1	(UnsignedCMP	),				// 无符号比较
		.i_JumpCode_8		(JumpBranchType ),				// 分支跳转类型
		.i_CompareSrc1_32	(CompareSrc1	),				// 分支类型比较操作数1
		.i_CompareSrc2_32	(CompareSrc2	),				// 分支类型比较操作数2
		.o_JumpBranch_1		(JumpBranch		)				// 分支跳转的标志
);

wire [31:0] MemoryLoadData;
wire [31:0] MemoryStoreData;
wire [31:0] MemoryAddr;
wire		MemoryWriteEnable;
wire [31:0] GRFWriteData;

memory memory(
		.i_ALUResult_32		(ALUResult		),				// ALU计算结果
		.i_Load_1			(Load			),				// 读指令信号
		.i_Store_1			(Store			),				// 写指令信号
		.i_LoadUnsigned_1	(LoadUnsigned	),				// 无符号拓展的读指令信号
		.i_LoadStoreWidth_2	(LoadStoreWidth	),				// 读写宽度 
		.i_StoreData_32		(StoreData		),				// 写指令的数据 
		.i_MemoryLoadData_32(MemoryLoadData ),				// 从内存中读取的数据
		.o_MemoryStoreData_32	(MemoryStoreData	),		// 写入到内存中的数据
		.o_MemoryAddr_32	(MemoryAddr		),				// 内存地址
		.o_MemoryWriteEnable_1	(MemoryWriteEnable	),		// 内存写使能
		.o_GRFWriteData_32	(GRFWriteData	)				// 写入到通用寄存器的数据
);

dist_mem_gen_0 DRam (
  .a(MemoryAddr[11:2]),      // input wire [9 : 0] a
  .d(MemoryStoreData),      // input wire [31 : 0] d
  .clk(clk),  // input wire clk
  .we(MemoryWriteEnable),    // input wire we
  .spo(MemoryLoadData)  // output wire [31 : 0] spo
);

regfile regfile(
		.clk				(clk			),				// 时钟信号 
		.rstn				(rstn			),				// 复位信号
		.i_wen				(GRFWen			),				// 通用寄存器写使能信号
		.i_waddr_5			(GRFWriteAddr	),				// 通用寄存器写接口地址
		.i_wdata_32			(GRFWriteData	),				// 通用寄存器写数据
		.i_raddr1_5			(GRFReadAddr1	),				// 通用寄存器读接口1的地址
		.i_raddr2_5			(GRFReadAddr2	),				// 通用寄存器读接口2的地址
		.o_rdata1_32		(GRFReadData1	),				// 通用寄存器读接口1的数据
		.o_rdata2_32		(GRFReadData2	)				// 通用寄存器读接口2的数据
);

assign o_Inst_32 = Inst;
endmodule
