`ifndef __RVG_HEADER__
    `define __RVG_HEADER__

//-----{RISC-V基本操作码(RISC-V base opcode)}
  `define OPCODE_LOAD         7'b0000011
  `define OPCODE_LOAD_FP      7'b0000111
  `define OPCODE_custom_0     7'b0001011
  `define OPCODE_MISC_MEM     7'b0001111
  `define OPCODE_OP_IMM       7'b0010011
  `define OPCODE_AUIPC        7'b0010111
  `define OPCODE_OP_IMM_32    7'b0011011
  `define OPCODE_48b          7'b0011111
  `define OPCODE_STORE        7'b0100011
  `define OPCODE_STORE_FP     7'b0100111
  `define OPCODE_custom_1     7'b0101011
  `define OPCODE_AMO          7'b0101111
  `define OPCODE_OP           7'b0110011
  `define OPCODE_LUI          7'b0110111
  `define OPCODE_OP_32        7'b0111011
  `define OPCODE_64b          7'b0111111
  `define OPCODE_MADD         7'b1000011
  `define OPCODE_MSUB         7'b1000111
  `define OPCODE_NMSUB        7'b1001011
  `define OPCODE_NMADD        7'b1001111
  `define OPCODE_OP_FP        7'b1010011
  `define OPCODE_reserved1    7'b1010111
  `define OPCODE_custom_2     7'b1011011
  `define OPCODE_rv128_1      7'b1011011
  `define OPCODE_BRANCH       7'b1100011
  `define OPCODE_JALR         7'b1100111
  `define OPCODE_reserved2    7'b1101011
  `define OPCODE_JAL          7'b1101111
  `define OPCODE_SYSTEM       7'b1110011
  `define OPCODE_reserved3    7'b1110111
  `define OPCODE_custom_3     7'b1111011
  `define OPCODE_rv128_2      7'b1111011
  `define OPCODE_80b          7'b1111111

//-----{RV32I funct3}

  // Jump Instruction
  `define FUNCT3_JALR         3'b000

  // Branch Instruction
  `define FUNCT3_BEQ          3'b000
  `define FUNCT3_BNE          3'b001
  `define FUNCT3_BLT          3'b100
  `define FUNCT3_BGE          3'b101
  `define FUNCT3_BLTU         3'b110
  `define FUNCT3_BGEU         3'b111

  // Load Instruction
  `define FUNCT3_LB           3'b000
  `define FUNCT3_LH           3'b001
  `define FUNCT3_LW           3'b010
  `define FUNCT3_LBU          3'b100
  `define FUNCT3_LHU          3'b101

  // Store Instruction
  `define FUNCT3_SB           3'b000
  `define FUNCT3_SH           3'b001
  `define FUNCT3_SW           3'b010

  // ALUI Operation
  `define FUNCT3_ADDI         3'b000
  `define FUNCT3_SLTI         3'b010
  `define FUNCT3_SLTIU        3'b011
  `define FUNCT3_XORI         3'b100
  `define FUNCT3_ORI          3'b110
  `define FUNCT3_ANDI         3'b111
  `define FUNCT3_SLLI         3'b001
  `define FUNCT3_SRLI         3'b101
  `define FUNCT3_SRAI         3'b101
  `define FUNCT3_ADD          3'b000
  `define FUNCT3_SUB          3'b000
  `define FUNCT3_SLL          3'b001
  `define FUNCT3_SLT          3'b010
  `define FUNCT3_SLTU         3'b011
  `define FUNCT3_XOR          3'b100
  `define FUNCT3_SRL          3'b101
  `define FUNCT3_SRA          3'b101
  `define FUNCT3_OR           3'b110
	`define FUNCT3_AND          3'b111

    // 一些特别的
  `define FUNCT3_FENCE        3'b000
	`define FUNCT3_PRIV         3'b000

//-----{RV32I FUNCT7}
	`define FUNCT7_SLLI			7'b0000000	
	`define FUNCT7_SRLI			7'b0000000	
	`define FUNCT7_ADD			7'b0000000	
	`define FUNCT7_SLL			7'b0000000	
	`define FUNCT7_SLT			7'b0000000	
	`define FUNCT7_SLTU			7'b0000000	
	`define FUNCT7_XOR			7'b0000000	
	`define FUNCT7_SRL			7'b0000000	
	`define FUNCT7_AND			7'b0000000	
	`define FUNCT7_OR				7'b0000000	

	`define FUNCT7_SRAI			7'b0100000	
	`define FUNCT7_SUB			7'b0100000	
	`define FUNCT7_SRA			7'b0100000	

//-----{FENCE FM}
  `define FM_FENCE            4'b0000
  `define FM_FENCE_TSO        4'b1000

//-----{RV32I funct12}
  `define FUNCT12_ECALL       12'b000000000000
  `define FUNCT12_EBREAK      12'b000000000001

	`define NOP									{25'b0,7'b0010011}

`endif
