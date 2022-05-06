`include "RVG.vh"
module ALUtoMEM_REG(
	input clk,
	input rstn,

	input [31:0] i_ALUResult_32,
	output[31:0] o_ALUResult_32,

	input				 i_Load_1,
	input				 i_Store_1,
	input				 i_LoadUnsigned_1,
	input [ 1:0] i_LoadStoreWidth_2,
	input [31:0] i_StoreData_32,
	input [ 4:0] i_GRFWriteAddr_5,
	input				 i_GRFWen_1,

	output			 o_Load_1,
	output			 o_Store_1,
	output			 o_LoadUnsigned_1,
	output[ 1:0] o_LoadStoreWidth_2,
	output[31:0] o_StoreData_32,
	output[ 4:0] o_GRFWriteAddr_5,
	output			 o_GRFWen_1
);

reg [31:0]	ALUResult;
reg					Load;
reg					Store;
reg					LoadUnsigned;
reg [ 1:0]	LoadStoreWidth;
reg [31:0]	StoreData;
reg [ 4:0]  GRFWriteAddr;
reg					GRFWen;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		ALUResult			<= 32'b0;
		Load					<= 1'b0;
		Store					<= 1'b0;
		LoadUnsigned	<= 1'b0;
		LoadStoreWidth<= 2'b0;
		StoreData			<= 32'b0;
		GRFWriteAddr	<= 5'b0;
		GRFWen				<= 1'b0;
	end	else begin
		ALUResult			<= i_ALUResult_32;
		Load					<= i_Load_1;
		Store					<= i_Store_1;
		LoadUnsigned	<= i_LoadUnsigned_1;
		LoadStoreWidth<= i_LoadStoreWidth_2;
		StoreData			<= i_StoreData_32;
		GRFWriteAddr	<= i_GRFWriteAddr_5;
		GRFWen				<= i_GRFWen_1;
	end
end

assign o_ALUResult_32			= ALUResult;
assign o_Load_1						= Load;
assign o_Store_1					= Store;
assign o_LoadUnsigned_1		= LoadUnsigned;
assign o_LoadStoreWidth_2 = LoadStoreWidth;
assign o_StoreData_32			= StoreData;
assign o_GRFWriteAddr_5		= GRFWriteAddr;
assign o_GRFWen_1					= GRFWen;

endmodule
