`include "RVG.vh"

module DEtoALU_REG(
		input clk,
		input rstn,

		// PC及指令
		input [31:0]	i_DecodePC_32,
		input [31:0]	i_Inst_32,
		output[31:0]	o_ALUPC_32,
		output[31:0]	o_Inst_32,

		// ALU使用
		input [11:0]	i_ALUControl_12,
		input [31:0]	i_ALUOperand1_32,
		input [31:0]  i_ALUOperand2_32,

		output[11:0]	o_ALUContro_12,
		output[31:0]	o_ALUOperand1_32,
		output[31:0]  o_ALUOperand2_32,

		// Memory使用
		input					i_Load_1,
		input					i_Store_1,
		input					i_LoadUnsigned_1,
		input [ 1:0]	i_LoadStoreWidth_2,
		input [31:0]	i_StoreData_32,
		
		output				o_Load_1,
		output				o_Store_1,
		output				o_LoadUnsigned_1,
		output[ 1:0]	o_LoadStoreWidth_2,
		output[31:0]	o_StoreData_32
);

reg [31:0] PC;
reg [31:0] Inst;

reg [11:0] ALUControl;
reg [31:0] ALUOperand1;
reg [31:0] ALUOperand2;

reg				 Load;
reg				 Store;
reg				 LoadUnsigned;
reg [ 1:0] LoadStoreWidth;
reg [31:0] StoreData;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		PC		<= 32'b0;
		Inst	<= `NOP;

		ALUControl	<= 12'b0;
		ALUOperand1 <= 32'b0;
		ALUOperand2 <= 32'b0;

		Load	<= 1'b0;
		Store <= 1'b0;
		LoadUnsigned	<= 1'b0;
		LoadStoreWidth<= 2'b0;
		StoreData			<= 32'b0;
	end	else begin
		PC		<= i_DecodePC_32;
		Inst	<= i_Inst_32;

		ALUControl	<= i_ALUControl_12;
		ALUOperand1 <= i_ALUOperand1_32;
		ALUOperand2 <= i_ALUOperand2_32;

		Load	<= i_Load_1;
		Store <= i_Store_1;
		LoadUnsigned	<= i_LoadUnsigned_1;
		LoadStoreWidth<= i_LoadStoreWidth_2;
		StoreData			<= i_StoreData_32;
	end
end

assign o_ALUPC_32 = PC;
assign o_Inst_32	= Inst;

assign o_ALUContro_12		= ALUControl;
assign o_ALUOperand1_32 = ALUOperand1;
assign o_ALUOperand2_32 = ALUOperand2;

assign o_Load_1		= Load;
assign o_Store_1	= Store;
assign o_LoadUnsigned_1		= LoadUnsigned;
assign o_LoadStoreWidth_2	= LoadStoreWidth;
assign o_StoreData_32			= StoreData;

endmodule
