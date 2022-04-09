module memory(

	// 从ALU输入的信号					(Signals input from ALU)	
	input [31:0]	i_ALUResult_32,

	// 从DECODE输入的信号				(Signals input from DECODE)
	input			i_Load_1,
	input			i_Store_1,
	input			i_LoadUnsigned_1,
	input [ 1:0]	i_LoadStoreWidth_2,
	input [31:0]	i_StoreData_32,

	// 从内存的输入信号					(Signals input from memory)	
	input [31:0]	i_MemoryLoadData_32,
	
	// 输出到内存的信号					(Signals output to memory)
	output[31:0]	o_MemoryStoreData_32,
	output			o_MemoryWriteEnable_1,

	// 输出到WB部分的信号				(Signals output to WB)
	output[31:0]	o_GRFWriteData_32
);

wire SW,SH,SB,LW,LH,LB;
wire [31:0]		SHData;
wire [31:0]		SBData;
wire [31:0]		LHData;
wire [31:0]		LBData;
wire [31:0]		DataWriteToGRF;
wire [31:0]		DataWriteToMem;
wire [31:0]		LoadData;

assign SW = i_Store_1 & i_LoadStoreWidth_2[1];
assign SH = i_Store_1 & i_LoadStoreWidth_2[0];
assign SB = i_Store_1 & ~|i_LoadStoreWidth_2;

assign LW = i_Load_1 & i_LoadStoreWidth_2[1];
assign LH = i_Load_1 & i_LoadStoreWidth_2[0];
assign LB = i_Load_1 & ~|i_LoadStoreWidth_2;

assign SHData				= {32{ i_ALUResult_32[1]}}	& {i_StoreData_32[15:0]				,i_MemoryLoadData_32[15:0]}
										| {32{~i_ALUResult_32[1]}}	& {i_MemoryLoadData_32[31:16]	,i_StoreData_32[15:0]			};

assign SBData				= {32{~|i_ALUResult_32[1:0]						}}	& {i_MemoryLoadData_32[31: 8]	,i_StoreData_32[ 7: 0]															}
										| {32{~i_ALUResult_32[1]& i_ALUResult_32[0] }}	& {i_MemoryLoadData_32[31:16]	,i_StoreData_32[15: 8]	,i_MemoryLoadData_32[ 7: 0]	}
										| {32{ i_ALUResult_32[1]&~i_ALUResult_32[0] }}	& {i_MemoryLoadData_32[31:24]	,i_StoreData_32[23:16]	,i_MemoryLoadData_32[15: 0]	}
										| {32{&i_ALUResult_32[1:0]									}}	& {															i_StoreData_32[31:24]	,i_MemoryLoadData_32[23: 0]	};

assign LHData				= {32{ i_ALUResult_32[1]}}	& {{16{~i_LoadUnsigned_1&i_MemoryLoadData_32[15]}}	,i_MemoryLoadData_32[15: 0]	}
										| {32{~i_ALUResult_32[1]}}	& {{16{~i_LoadUnsigned_1&i_MemoryLoadData_32[31]}}	,i_MemoryLoadData_32[31:16]	};


assign LBData				= {32{~|i_ALUResult_32[1:0]					}}	& {{24{~i_LoadUnsigned_1&i_MemoryLoadData_32[ 7]}}	,i_MemoryLoadData_32[ 7: 0]	}
										| {32{~i_ALUResult_32[1]& i_ALUResult_32[0] }}	& {{24{~i_LoadUnsigned_1&i_MemoryLoadData_32[15]}}	,i_MemoryLoadData_32[15: 8]	}
										| {32{ i_ALUResult_32[1]&~i_ALUResult_32[0] }}	& {{24{~i_LoadUnsigned_1&i_MemoryLoadData_32[23]}}	,i_MemoryLoadData_32[23:16]	}
										| {32{&i_ALUResult_32[1:0]					}}	& {{24{~i_LoadUnsigned_1&i_MemoryLoadData_32[31]}}	,i_MemoryLoadData_32[31:24]	};

assign DataWriteToMem		= {32{SW}}	& i_StoreData_32
												| {32{SH}}	& SHData
												| {32{SB}}	& SBData		;

assign LoadData				= {32{LW}}	& i_MemoryLoadData_32
											| {32{LH}}	& LHData
											| {32{LB}}	& LBData		;

assign DataWriteToGRF		= {32{ i_Load_1	}} & LoadData
												| {32{~i_Load_1 }} & i_ALUResult_32		;	

assign o_MemoryStoreData_32 = DataWriteToMem;

assign o_MemoryWriteEnable_1= i_Store_1;

assign o_GRFWriteData_32	= DataWriteToGRF;
							
endmodule
