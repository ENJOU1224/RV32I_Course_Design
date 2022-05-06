module cpu_top(
	input clk,
	input rstn,
	output o_GRFWriteData
);
wire [31:0]		PCPlus4;
wire [31:0]		JumpBranchAddr;
wire					JumpBranchInDE;
wire					JumpBranchInALU;
wire [31:0]		DEPC;
wire [31:0]		NextPC;
wire [31:0]		Inst;

(* keep_hierarchy = "yes" *)instfetch instfetch(
		.i_JumpBranchAddr_32	(JumpBranchAddr		),		// 分支跳转的目的地址
		.i_JumpBranchInDE_1		(JumpBranchInDE		),		// 目前Decode中指令触发分支跳转
		.i_JumpBranchInALU_1	(JumpBranchInALU	),		// 目前ALU中指令触发分支跳转
		.i_PC_32							(DEPC								),		// 已发射指令PC
		.o_NextPC_32					(NextPC						),		// 待发射指令PC
		.o_PCPlus4_32					(PCPlus4					)			// PC+4,分支跳转用
);

wire [31:0] DEPCPlus4;

(* keep_hierarchy = "yes" *)IFtoDE_REG IFtoDE_REG(
		.clk									(clk						),
		.rstn									(rstn						),
		.i_NextPC_32					(NextPC					),
		.i_PCPlus4_32					(PCPlus4				),
		.o_PCPlus4_32					(DEPCPlus4			),
		.o_PC_32							(DEPC						)
);

(* keep_hierarchy = "yes" *)blk_mem_gen_0 IRom (
  .clka(clk),    // input wire clka
  .addra(NextPC),  // input wire [31 : 0] addra
  .douta(Inst)  // output wire [31 : 0] douta
);

wire [ 4:0] GRFReadAddr1;
wire [ 4:0] GRFReadAddr2;
wire [31:0] GRFReadData1;
wire [31:0] GRFReadData2;
wire [ 4:0] DE_GRFWriteAddr;
wire				DE_GRFWen;
wire [11:0] DE_ALUControl;
wire [31:0] DE_ALUOperand1;
wire [31:0] DE_ALUOperand2;
wire				DE_Load;
wire				DE_Store;
wire				DE_LoadUnsigned;
wire [ 1:0] DE_LoadStoreWidth;
wire [31:0] DE_StoreData;
wire [ 7:0] JumpBranchType;
wire [31:0] CompareSrc1;
wire [31:0] CompareSrc2;
wire				UnsignedCMP;

(* keep_hierarchy = "yes" *)decode decode(
		.rstn								(rstn							),
		.PC									(DEPC							),				// 当前指令PC
		.i_Inst_32					(Inst							),				// 当前指令
		.o_GRFReadAddr1_5		(GRFReadAddr1			),				// 通用寄存器读接口1的地址
		.o_GRFReadAddr2_5		(GRFReadAddr2			),				// 通用寄存器读接口2的地址
		.i_GRFReadData1_32	(GRFReadData1			),				// 通用寄存器读接口1的数据
		.i_GRFReadData2_32	(GRFReadData2			),				// 通用寄存器读接口2的数据
		.o_GRFWriteAddr_5		(DE_GRFWriteAddr	),				// 通用寄存器写接口地址
		.o_GRFWen_1					(DE_GRFWen				),				// 通用寄存器写使能信号
		.o_ALUControl_12		(DE_ALUControl		),				// ALU控制信号
		.o_ALUOperand1_32		(DE_ALUOperand1		),				// ALU操作数1
		.o_ALUOperand2_32		(DE_ALUOperand2		),				// ALU操作数2
		.o_Load_1						(DE_Load					),				// 读指令信号
		.o_Store_1					(DE_Store					),				// 写指令信号
		.o_LoadUnsigned_1		(DE_LoadUnsigned	),				// 无符号拓展的读指令信号
		.o_LoadStoreWidth_2 (DE_LoadStoreWidth),				// 读写宽度
		.o_StoreData_32			(DE_StoreData			),				// 写指令的数据
		.o_JumpBranchType_8 (JumpBranchType		),				// 分支跳转类型
		.o_CompareSrc1_32		(CompareSrc1			),				// 分支类型比较操作数1
		.o_CompareSrc2_32		(CompareSrc2			),				// 分支类型比较操作数2
		.o_UnsignedCMP_1		(UnsignedCMP			)					// 无符号比较
);


wire [31:0] ALUInst;
wire [31:0] ALUPC;
wire [31:0] ALUPCPlus4;

wire [11:0] ALU_ALUControl;
wire [31:0] ALU_ALUOperand1;
wire [31:0] ALU_ALUOperand2;
wire				ALU_Load;
wire				ALU_Store;
wire				ALU_LoadUnsigned;
wire [ 1:0] ALU_LoadStoreWidth;
wire [31:0] ALU_StoreData;
wire [ 4:0] ALU_GRFWriteAddr;
wire				ALU_GRFWen;

(* keep_hierarchy = "yes" *)DEtoALU_REG DEtoALU_REG(
		.clk										(clk								),
		.rstn										(rstn								),
		.i_DecodePC_32					(DEPC								),
		.i_Inst_32							(Inst								),
		.o_ALUPC_32							(ALUPC							),
		.i_PCPlus4_32						(DEPCPlus4					),
		.o_PCPlus4_32						(ALUPCPlus4					),

		.i_ALUControl_12				(DE_ALUControl			),
		.i_ALUOperand1_32				(DE_ALUOperand1			),
		.i_ALUOperand2_32				(DE_ALUOperand2			),
		.o_ALUControl_12				(ALU_ALUControl			),
		.o_ALUOperand1_32				(ALU_ALUOperand1		),
		.o_ALUOperand2_32				(ALU_ALUOperand2		),


		.i_Load_1								(DE_Load						),
		.i_Store_1							(DE_Store						),
		.i_LoadUnsigned_1				(DE_LoadUnsigned		),
		.i_StoreData_32					(DE_StoreData				),
		.i_LoadStoreWidth_2			(DE_LoadStoreWidth	),
		.i_GRFWriteAddr_5				(DE_GRFWriteAddr		),
		.i_GRFWen_1							(DE_GRFWen					),
		.o_Load_1								(ALU_Load						),
		.o_Store_1							(ALU_Store					),
		.o_LoadUnsigned_1				(ALU_LoadUnsigned		),
		.o_StoreData_32					(ALU_StoreData			),
		.o_GRFWriteAddr_5				(ALU_GRFWriteAddr		),
		.o_GRFWen_1							(ALU_GRFWen					),
		
		.i_JumpBranch_1					(JumpBranchInDE			),
		.o_JumpBranch_1					(JumpBranchInALU		)
);

wire [31:0] ALU_ALUResult;

(* keep_hierarchy = "yes" *)alu alu(
		.PC									(ALUPC					),				// 当前指令PC
		.i_PCPlus4_32				(ALUPCPlus4			),
		.i_ALUControl_12		(ALU_ALUControl	),				// ALU控制信号
		.i_ALUOperand1_32		(ALU_ALUOperand1),				// ALU操作数1 
		.i_ALUOperand2_32		(ALU_ALUOperand2),				// ALU操作数2
		.o_JumpBranchAddr_32(JumpBranchAddr	),				// 分支跳转的目的地址
		.o_ALUResult_32			(ALU_ALUResult	)					// ALU计算结果
);

(* keep_hierarchy = "yes" *)JumpBranchControl JumpBranchControl(
		.i_UnsignedCMP_1	(UnsignedCMP		),				// 无符号比较
		.i_JumpCode_8			(JumpBranchType ),				// 分支跳转类型
		.i_CompareSrc1_32	(CompareSrc1		),				// 分支类型比较操作数1
		.i_CompareSrc2_32	(CompareSrc2		),				// 分支类型比较操作数2
		.o_JumpBranch_1		(JumpBranchInDE	)				// 分支跳转的标志
);

wire [31:0] MemoryLoadData;
wire [31:0] MemoryStoreData;
wire [31:0] MemoryAddr;
wire		MemoryWriteEnable;
wire [31:0] GRFWriteData;

wire [31:0] MEM_ALUResult;
wire				MEM_Load;
wire				MEM_Store;
wire				MEM_LoadUnsigned;
wire [ 1:0] MEM_LoadStoreWidth;
wire [31:0] MEM_StoreData;
wire [31:0] MEM_StoreAddr;
wire [ 4:0] GRFWriteAddr;
wire				GRFWen;

(* keep_hierarchy = "yes" *)ALUtoMEM_REG ALUtoMEM_REG(
		.clk								(clk								),
		.rstn								(rstn								),
		.i_ALUResult_32			(ALU_ALUResult			),
		.i_Load_1						(ALU_Load						),
		.i_Store_1					(ALU_Store					),
		.i_LoadUnsigned_1		(ALU_LoadUnsigned		),
		.i_LoadStoreWidth_2 (ALU_LoadStoreWidth ),
		.i_StoreData_32			(ALU_StoreData			),
		.i_GRFWriteAddr_5		(ALU_GRFWriteAddr		),
		.i_GRFWen_1					(ALU_GRFWen					),
		.o_ALUResult_32			(MEM_ALUResult			),
		.o_Load_1						(MEM_Load						),
		.o_Store_1					(MEM_Store					),
		.o_LoadUnsigned_1		(MEM_LoadUnsigned		),
		.o_LoadStoreWidth_2 (MEM_LoadStoreWidth ),
		.o_StoreData_32			(MEM_StoreData			),
		.o_GRFWriteAddr_5		(GRFWriteAddr				),
		.o_GRFWen_1					(GRFWen							)
);
(* keep_hierarchy = "yes" *)memory memory(
		.i_ALUResult_32					(MEM_ALUResult			),				// ALU计算结果
		.i_Load_1								(MEM_Load						),				// 读指令信号
		.i_Store_1							(MEM_Store					),				// 写指令信号
		.i_LoadUnsigned_1				(MEM_LoadUnsigned		),				// 无符号拓展的读指令信号
		.i_LoadStoreWidth_2			(MEM_LoadStoreWidth	),				// 读写宽度 
		.i_StoreData_32					(MEM_StoreData			),				// 写指令的数据 
		.i_MemoryLoadData_32		(MemoryLoadData			),				// 从内存中读取的数据
		.o_MemoryStoreAddr_32		(MEM_StoreAddr			),
		.o_MemoryStoreData_32		(MemoryStoreData		),				// 写入到内存中的数据
		.o_MemoryWriteEnable_1	(MemoryWriteEnable	),				// 内存写使能
		.o_GRFWriteData_32			(GRFWriteData				)					// 写入到通用寄存器的数据
);

(* keep_hierarchy = "yes" *)blk_mem_gen_1 DRam (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(MemoryStoreAddr),  // input wire [11 : 0] addra
  .dina(MemoryStoreData),    // input wire [31 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(ALU_ALUResult),  // input wire [11 : 0] addrb
  .doutb(MemoryLoadData)  // output wire [31 : 0] doutb
);
(* keep_hierarchy = "yes" *)regfile regfile(
		.clk						(clk					),				// 时钟信号 
		.rstn						(rstn					),				// 复位信号
		.i_wen					(GRFWen				),				// 通用寄存器写使能信号
		.i_waddr_5			(GRFWriteAddr	),				// 通用寄存器写接口地址
		.i_wdata_32			(GRFWriteData	),				// 通用寄存器写数据
		.i_raddr1_5			(GRFReadAddr1	),				// 通用寄存器读接口1的地址
		.i_raddr2_5			(GRFReadAddr2	),				// 通用寄存器读接口2的地址
		.o_rdata1_32		(GRFReadData1	),				// 通用寄存器读接口1的数据
		.o_rdata2_32		(GRFReadData2	)					// 通用寄存器读接口2的数据
);

endmodule
