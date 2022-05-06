module change(
	input [ 4:0] DE_GRFReadAddr1_5,
	input [ 4:0] DE_GRFReadAddr2_5,

	input [ 4:0] ALU_GRFWriteAddr_5,
	input				 ALU_Load_1,

	input [ 4:0] MEM_GRFWriteAddr_5,
	input				 MEM_Load_1,
	input	[31:0] MEM_GRFWriteData_32

);

endmodule
