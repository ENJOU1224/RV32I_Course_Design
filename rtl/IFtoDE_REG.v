module IFtoDE_REG(
		input clk,
		input rstn,
		input [31:0] i_NextPC_32,
		output[31:0] o_PC_32,

		input [31:0] i_PCPlus4_32,
		output[31:0] o_PCPlus4_32
);

reg [31:0] PC;
reg [31:0] PCPlus4;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		PC			<= 32'b0;	
		PCPlus4 <= 32'h4;
	end else begin
		PC			<= i_NextPC_32;
		PCPlus4 <= i_PCPlus4_32;
	end
end

assign o_PC_32			= PC;
assign o_PCPlus4_32 = PCPlus4;

endmodule
