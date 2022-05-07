module forward(
	input [ 4:0] DE_GRFReadAddr1_5,
	input [ 4:0] DE_GRFReadAddr2_5,
	output[31:0] DE_GRFReadData1_32,
	output[31:0] DE_GRFReadData2_32,

	input [ 4:0] ALU_GRFWriteAddr_5,
	input				 ALU_GRFWen_1,
	input				 ALU_Load_1,
	input [31:0] ALU_ALUResult_32,

	input [ 4:0] MEM_GRFWriteAddr_5,
	input				 MEM_GRFWen_1,
	input	[31:0] MEM_GRFWriteData_32,

	output[ 4:0] GRFReadAddr1_5,
	output[ 4:0] GRFReadAddr2_5,
	
	input [31:0] GRFReadData1_32,
	input [31:0] GRFReadData2_32,

	output			 WaitLoad_1
);

wire [31:0]GRFReadData1;
wire [31:0]GRFReadData2;

wire ALUtoDEForward1	= ALU_GRFWen_1 & ~ALU_Load_1 & ~|(DE_GRFReadAddr1_5 ^ ALU_GRFWriteAddr_5); 
wire ALUtoDEForward2	= ALU_GRFWen_1 & ~ALU_Load_1 & ~|(DE_GRFReadAddr2_5 ^ ALU_GRFWriteAddr_5); 

wire MEMtoDEForward1	= MEM_GRFWen_1 & ~|(DE_GRFReadAddr1_5 ^ MEM_GRFWriteAddr_5); 
wire MEMtoDEForward2	= MEM_GRFWen_1 & ~|(DE_GRFReadAddr2_5 ^ MEM_GRFWriteAddr_5); 

assign GRFReadData1 = {32{ ALUtoDEForward1									}} & ALU_ALUResult_32
										| {32{~ALUtoDEForward1 & MEMtoDEForward1}} & MEM_GRFWriteData_32
										| {32{~ALUtoDEForward1 &~MEMtoDEForward1}} & GRFReadData1_32;

assign GRFReadData2 = {32{ ALUtoDEForward2									}} & ALU_ALUResult_32
										| {32{~ALUtoDEForward2 & MEMtoDEForward2}} & MEM_GRFWriteData_32
										| {32{~ALUtoDEForward2 &~MEMtoDEForward2}} & GRFReadData2_32;
													
assign DE_GRFReadData1_32 = GRFReadData1 & {32{|DE_GRFReadAddr1_5}};
assign DE_GRFReadData2_32 = GRFReadData2 & {32{|DE_GRFReadAddr2_5}};

assign GRFReadAddr1_5	= DE_GRFReadAddr1_5;
assign GRFReadAddr2_5	= DE_GRFReadAddr2_5;
assign WaitLoad_1			= ALU_Load_1 & ( ~|(DE_GRFReadAddr1_5 ^ ALU_GRFWriteAddr_5) | ~|(DE_GRFReadAddr1_5 ^ ALU_GRFWriteAddr_5) );  

endmodule
