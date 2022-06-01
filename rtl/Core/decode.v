/*
    -- ============================================================================
    -- FILE NAME	: decode.v
    -- DESCRIPTION :  指令解码及控制信号生成 
    -- ----------------------------------------------------------------------------
    -- Revision  Date		  Coding_by	 Comment
    -- 1.5.0	  2022/03/24  enjou		 整合了分支跳转 
    -- ============================================================================
*/
`include "RVG.vh"

module decode (
	input		rstn,

  input   [31:0]  PC,
  input   [31:0]  i_Inst_32,

  // 通用寄存器连接					(General Register Connection)
  output  [ 4:0]  o_GRFReadAddr1_5,
	output  [ 4:0]  o_GRFReadAddr2_5,
	input   [31:0]  i_GRFReadData1_32,
  input   [31:0]  i_GRFReadData2_32,

	output	[ 4:0]	o_GRFWriteAddr_5,
	output					o_GRFWen_1,

	// 输出到EX部分						(Output to EX Part)
	output	[11:0]	o_ALUControl_12,
	output  [31:0]	o_ALUOperand1_32,
	output  [31:0]	o_ALUOperand2_32,

	// 输出到Memory部分					(Output to Memory Part)
	output					o_Load_1,
	output					o_Store_1,
	output					o_LoadUnsigned_1,
	output	[ 1:0]	o_LoadStoreWidth_2,
	output  [31:0]	o_StoreData_32,

	// 输出到JumpBranchControl部分		(Output to JumpBranchControl Part)
	output	[ 7:0]	o_JumpBranchType_8,
	output	[31:0]	o_CompareSrc1_32,
	output	[31:0]	o_CompareSrc2_32,
	output					o_UnsignedCMP_1
);

wire [31:0] Inst = {32{rstn}} &i_Inst_32;

//------------------------------指令区域划分(Instruction Subfield Division){begin}------------------------------//

    wire [ 6:0] funct7;
    wire [ 2:0] funct3;
    wire [11:0] funct12;
    wire [ 4:0] rs2;
    wire [ 4:0] rs1;
    wire [ 4:0] rd;
    wire [ 6:0] opcode;
		wire [19:0] imm20;
    wire [11:0] imm12;
		wire [11:0] imm12_B;
		wire [ 6:0] imm7;
		wire [ 4:0] imm5;
    wire [19:0] U_imm;

    assign funct7   = Inst[31:25];
    assign funct3   = Inst[14:12];
    assign funct12  = Inst[31:20];
    assign rs2      = Inst[24:20];
    assign rs1      = Inst[19:15];
    assign rd       = Inst[11: 7];
    assign opcode   = Inst[ 6: 0];
		assign imm20	= {Inst[31],Inst[19:12],Inst[20],Inst[30:21]};
		assign imm12	= Inst[31:20];
		assign imm12_B	= {Inst[31],Inst[7],Inst[30:25],Inst[11:8]};
		assign imm7		= Inst[31:25];
		assign imm5		= Inst[11: 7];
		assign U_imm	= Inst[31:12];

//------------------------------指令区域划分(Instruction Subfield Division){begin}------------------------------//

//------------------------------实现指令列表(List of implemented instructions){begin}------------------------------//

    //----------整数运算指令(Interger Computational Instructions)----------//

    // 整型寄存器立即数间操作                               (Integer Register-Immediate Operations)
    wire Inst_ADDI  ,Inst_SLTI  ,Inst_SLTIU ,Inst_ANDI
        ,Inst_ORI   ,Inst_XORI  ;
    wire Inst_SLLI  ,Inst_SRLI  ,Inst_SRAI  ,Inst_LUI
        ,Inst_AUIPC ;

    // 整型寄存器间操作                                     (Integer Register-Register Operations)
    wire Inst_ADD   ,Inst_SLT   ,Inst_SLTU  ,Inst_AND
        ,Inst_OR    ,Inst_XOR   ,Inst_SLL   ,Inst_SRL
        ,Inst_SUB   ,Inst_SRA   ;

    //----------控制权转移指令(Control Transfer Instructions)----------//

    // 无条件跳转                                           (Unconditional Jumps)
    wire Inst_JAL   ,Inst_JALR  ;

    // 条件分支                                             (Conditional Branches)
    wire Inst_BEQ   ,Inst_BNE	,Inst_BLT	,Inst_BLTU  
		,Inst_BGE   ,Inst_BGEU  ;

    //----------读写指令(Load and Store Instructions)----------//

    wire Inst_LB    ,Inst_LH    ,Inst_LW    ,Inst_LBU
        ,Inst_LHU   ,Inst_SB    ,Inst_SH    ,Inst_SW    ;

    //----------内存序指令(Memory Ordering Instructions)----------//
    wire Inst_FENCE ,Inst_FENCETSO ;

    //----------环境调用及断点(Environment Call and Breakpoints)----------//
    wire Inst_PAUSE ,Inst_ECALL ,Inst_EBREAK;


//------------------------------实现指令列表(List of implemented instructions){end}------------------------------//

//------------------------------指令译码(Instruction Decode){begin}------------------------------//

    //----------整数运算指令(Interger Computational Instructions)----------//

    // 整型寄存器立即数间操作                               (Integer Register-Immediate Operations)
    assign Inst_ADDI    = {{funct3 == `FUNCT3_ADDI  } & {opcode == `OPCODE_OP_IMM   }};
    assign Inst_SLTI    = {{funct3 == `FUNCT3_SLTI  } & {opcode == `OPCODE_OP_IMM   }};
    assign Inst_SLTIU   = {{funct3 == `FUNCT3_SLTIU } & {opcode == `OPCODE_OP_IMM   }};
    assign Inst_ANDI    = {{funct3 == `FUNCT3_ANDI  } & {opcode == `OPCODE_OP_IMM   }};
    assign Inst_ORI     = {{funct3 == `FUNCT3_ORI   } & {opcode == `OPCODE_OP_IMM   }};
    assign Inst_XORI    = {{funct3 == `FUNCT3_XORI  } & {opcode == `OPCODE_OP_IMM   }};
    assign Inst_SLLI    = {{funct3 == `FUNCT3_SLLI  } & {opcode == `OPCODE_OP_IMM   } & {funct7 == `FUNCT7_SLLI}};
    assign Inst_SRLI    = {{funct3 == `FUNCT3_SRLI  } & {opcode == `OPCODE_OP_IMM   } & {funct7 == `FUNCT7_SRLI}};
    assign Inst_SRAI    = {{funct3 == `FUNCT3_SRAI  } & {opcode == `OPCODE_OP_IMM   } & {funct7 == `FUNCT7_SRAI}};
    assign Inst_LUI     = { opcode == `OPCODE_LUI   };
    assign Inst_AUIPC   = { opcode == `OPCODE_AUIPC };

    // 整型寄存器间操作                                     (Integer Register-Register Operations)
    assign Inst_ADD     = {{funct3 == `FUNCT3_ADD   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_ADD}};
    assign Inst_SLT     = {{funct3 == `FUNCT3_SLT   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_SLT}};
    assign Inst_SLTU    = {{funct3 == `FUNCT3_SLTU  } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_SLTU}};
    assign Inst_AND     = {{funct3 == `FUNCT3_AND   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_AND}};
    assign Inst_OR      = {{funct3 == `FUNCT3_OR    } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_OR}};
    assign Inst_XOR     = {{funct3 == `FUNCT3_XOR   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_XOR}};
    assign Inst_SLL     = {{funct3 == `FUNCT3_SLL   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_SLL}};
    assign Inst_SRL     = {{funct3 == `FUNCT3_SRL   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_SRL}};
    assign Inst_SUB     = {{funct3 == `FUNCT3_SUB   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_SUB}};
    assign Inst_SRA     = {{funct3 == `FUNCT3_SRA   } & {opcode == `OPCODE_OP       } & {funct7 == `FUNCT7_SRA}};

    //----------控制权转移指令(Control Transfer Instructions)----------//

    // 无条件跳转                                           (Unconditional Jumps)
    assign Inst_JAL     = { opcode == `OPCODE_JAL   };
    assign Inst_JALR    = {{funct3 == `FUNCT3_JALR  } & {opcode == `OPCODE_JALR     }};

    // 条件分支                                             (Conditional Branches)
    assign Inst_BEQ     = {{funct3 == `FUNCT3_BEQ   } & {opcode == `OPCODE_BRANCH }};
		assign Inst_BNE			= {{funct3 == `FUNCT3_BNE		}	& {opcode == `OPCODE_BRANCH	}};
		assign Inst_BLT			= {{funct3 == `FUNCT3_BLT		}	& {opcode == `OPCODE_BRANCH	}};
		assign Inst_BLTU		= {{funct3 == `FUNCT3_BLTU	} & {opcode == `OPCODE_BRANCH	}};
		assign Inst_BGE			= {{funct3 == `FUNCT3_BGE		}	& {opcode == `OPCODE_BRANCH	}};
		assign Inst_BGEU		= {{funct3 == `FUNCT3_BGEU	} & {opcode == `OPCODE_BRANCH	}};

	//----------读写指令(Load and Store Instructions)----------//
    assign Inst_LB      = {{funct3 == `FUNCT3_LB    } & {opcode == `OPCODE_LOAD     }};
    assign Inst_LH      = {{funct3 == `FUNCT3_LH    } & {opcode == `OPCODE_LOAD     }};
    assign Inst_LW      = {{funct3 == `FUNCT3_LW    } & {opcode == `OPCODE_LOAD     }};
    assign Inst_LBU     = {{funct3 == `FUNCT3_LBU   } & {opcode == `OPCODE_LOAD     }};
    assign Inst_LHU     = {{funct3 == `FUNCT3_LHU   } & {opcode == `OPCODE_LOAD     }};
    assign Inst_SB      = {{funct3 == `FUNCT3_SB    } & {opcode == `OPCODE_STORE    }};
    assign Inst_SH      = {{funct3 == `FUNCT3_SH    } & {opcode == `OPCODE_STORE    }};
    assign Inst_SW      = {{funct3 == `FUNCT3_SW    } & {opcode == `OPCODE_STORE    }};

    //----------内存序指令(Memory Ordering Instructions)----------//
    assign Inst_FENCE   = {{funct3 == `FUNCT3_FENCE } & {opcode == `OPCODE_MISC_MEM }};
    assign Inst_FENCETSO= {{funct3 == `FUNCT3_FENCE } & {opcode == `OPCODE_MISC_MEM }};
    assign Inst_PAUSE   = {{funct3 == `FUNCT3_FENCE } & {opcode == `OPCODE_MISC_MEM }};

    //----------环境调用及断点(Environment Call and Breakpoints)----------//
    assign Inst_ECALL   = {{funct3 == `FUNCT3_PRIV  } & {opcode == `OPCODE_SYSTEM   } & {funct12 == `FUNCT12_ECALL  }};
    assign Inst_EBREAK  = {{funct3 == `FUNCT3_PRIV  } & {opcode == `OPCODE_SYSTEM   } & {funct12 == `FUNCT12_EBREAK }};

//------------------------------指令译码(Instruction Decode){begin}------------------------------//

//------------------------------指令分类(Instruction classification){begin}------------------------------//

    //----------根据指令结构类型分类(Classification according to the type of instruction structure)----------//
    wire R_Type;
    wire I_Type;
    wire S_Type;
    wire B_Type;
    wire U_Type;
    wire J_Type;

    assign I_Type   = Inst_ADDI |Inst_SLTI  |Inst_SLTIU |Inst_ANDI
                    | Inst_ORI  |Inst_XORI  |Inst_SLLI  |Inst_SRLI
                    | Inst_SRAI |Inst_LW		| Inst_LH   |Inst_LB    
										| Inst_LHU  |Inst_LBU		| Inst_ECALL|Inst_EBREAK
										| Inst_JALR	;

    assign R_Type   = Inst_ADD  |Inst_SLT   |Inst_SLTU  |Inst_AND
                    | Inst_OR   |Inst_XOR   |Inst_SLL   |Inst_SRL
                    | Inst_SUB  |Inst_SRA   ;

    assign J_Type   = Inst_JAL  ;

    assign B_Type   = Inst_BEQ  |Inst_BNE   |Inst_BLT   |Inst_BLTU
                    | Inst_BGE  |Inst_BGEU  ;

    assign S_Type   = Inst_SW   |Inst_SH    |Inst_SB    ;

		assign U_Type		= Inst_LUI	|Inst_AUIPC	;


    //----------根据ALU操作类型分类(Classification according to the type of ALU operation)----------//
		wire	ADD	, SUB	, SLT	, SLTU	,
					AND , OR	, XOR	, SLL	,
					SRL , SRA	, LUI	, PC4	;

	assign ADD	= Inst_ADDI	|Inst_ADD	|Inst_LB 
							| Inst_LH		|Inst_LW	|Inst_LBU
							| Inst_LHU	|Inst_SB	|Inst_SH
							| Inst_SW		|Inst_AUIPC	;

	assign PC4	= Inst_JAL	|Inst_JALR	;

	assign SUB	= Inst_SUB	;

	assign SLT	= Inst_SLT	|Inst_SLTI	;

	assign SLTU = Inst_SLTU |Inst_SLTIU ;

	assign AND	= Inst_AND	|Inst_ANDI	;

	assign OR		= Inst_OR	|Inst_ORI	;
							
	assign XOR	= Inst_XOR	|Inst_XORI	;

	assign SLL	= Inst_SLL	|Inst_SLLI	; 

	assign SRL	= Inst_SRL	|Inst_SRLI	;

	assign SRA	= Inst_SRA	|Inst_SRAI	;

	assign LUI	= Inst_LUI	;

    //----------根据指令带有的数据类型分类(Classification according to the type of date attached with instructions)----------//
	wire  WithRS2	, WithImm	;

	assign WithRS2	= R_Type	;

	assign WithImm	= I_Type|S_Type	|U_Type	|J_Type	|B_Type;
	
    //----------根据指令的访存类型分类(Classification according to the type of Load Store operation)----------//
	wire [1:0]	LoadStoreWidth;		// 读写长度
	wire				Load;							// 读取指令
	wire				Store;						// 写指令
	wire				LoadUnsigned;			// 读取符号补全方式

	assign Load			= Inst_LB	|Inst_LH	|Inst_LW	|Inst_LBU	|Inst_LHU;

	assign Store		= Inst_SB	|Inst_SH	|Inst_SW	;

	assign LoadUnsigned		= Inst[14];					// 指令该位区分了无符号读

	assign LoadStoreWidth	= Inst[13:12];				// 指令的这两位区分了store宽度

	//----------根据跳转比较符号情况分类(Classification according to the jump comparison symbol case)
	wire UnsignedCMP;	

	assign UnsignedCMP	= Inst_BLTU	|Inst_BGEU	;

    //----------特殊操作数(Special Operand1PC)----------//
	wire Operand1PC;		// 源操作数1为PC

	assign Operand1PC	= J_Type	|B_Type		|Inst_AUIPC	;

//------------------------------指令译码(Instruction Decode){end}------------------------------//
	

//------------------------------输出信号生成(Output signal generation){end}------------------------------//
	
	// 输出信号定义
	wire [31:0] imm_32;				// 输出立即数操作数
	wire [11:0] ALUControl;		// ALU控制（独热码）
	wire [31:0] ALUOperand1;	// ALU操作数1
	wire [31:0] ALUOperand2;	// ALU操作数2
	wire				GRF_Wen;				// 通用寄存器写使能
	wire [ 7:0] JumpBranchType;	// 跳转分支类型 

	// 输出信号逻辑生成								
	assign imm_32		= {{32{ I_Type	}}	& {{20{imm12[11]}}	, imm12	& {1'b1,~Inst_SRAI,10'h3FF}}} 
									| {{32{ S_Type	}}	& {{20{imm7[6]	}}	, imm7		,imm5	}}
									| {{32{ U_Type	}}	& { U_imm , 12'd0										}}
									| {{32{ B_Type	}}	& {{19{imm12_B[11]}}, imm12_B	,1'b0	}}
									| {{32{ J_Type	}}	& {{11{imm20[19]}}	, imm20		,1'b0	}};

	assign GRF_Wen	= R_Type		|U_Type			|J_Type			|I_Type;

	assign ALUControl	= {
							ADD	,
							PC4 ,
							SUB ,
							SLT ,
							SLTU,
							AND ,
							OR	,
							XOR ,
							SLL ,
							SRL ,
							SRA ,
							LUI 
								};

	assign ALUOperand1	= {{32{ Operand1PC	}}	& PC				}
											| {{32{~Operand1PC	}}	& i_GRFReadData1_32	};
														
	assign ALUOperand2	= {{32{ WithRS2		}}	& i_GRFReadData2_32	}
						| {{32{ WithImm		}}	& imm_32			};

	assign JumpBranchType	= {
							Inst_JAL	,
							Inst_JALR	,
							Inst_BEQ	,
							Inst_BNE	,
							Inst_BLT	,
							Inst_BLTU	,
							Inst_BGE	,
							Inst_BGEU 
										};


	// 输出信号输出								(Output the Output Signal)
	assign o_GRFReadAddr1_5 = rs1;
	
	assign o_GRFReadAddr2_5 = rs2;

	assign o_GRFWriteAddr_5 = rd;

	assign o_GRFWen_1		= GRF_Wen;

	assign o_Load_1			= Load;

	assign o_Store_1		= Store;

	assign o_ALUControl_12	= ALUControl;

	assign o_LoadUnsigned_1	= LoadUnsigned;

	assign o_LoadStoreWidth_2	= LoadStoreWidth;

	assign o_ALUOperand1_32 = ALUOperand1;
	
	assign o_ALUOperand2_32 = ALUOperand2;

	assign o_JumpBranchType_8	= JumpBranchType;

	assign o_UnsignedCMP_1	= UnsignedCMP;
	
	assign o_CompareSrc1_32	= i_GRFReadData1_32;
	
	assign o_CompareSrc2_32	= i_GRFReadData2_32;

	assign o_StoreData_32	= i_GRFReadData2_32;
endmodule
