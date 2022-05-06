module IFtoDE_REG(
		input clk,
		input rstn,
		input [31:0] i_NextPC_32,
		output[31:0] o_PC_32
);

reg [31:0] PC;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		PC <= 32'b0;	
	end else begin
		PC <= i_NextPC_32;
	end
end

assign o_PC_32 = PC;

endmodule
