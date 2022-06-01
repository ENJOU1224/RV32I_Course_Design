/*
-- ================================================================================================
-- FILE NAME   : regfile.v
-- DESCRIPTION : 寄存器堆模块,同步写,异步读
-- ------------------------------------------------------------------------------------------------
-- Revision Date        Coding_by   Comment
-- 1.0.0    2021/09/29  enjou       初版
-- ================================================================================================
*/
module regfile (

    // 时钟复位信号     (Clock and Reset)
    input               clk,
	input				rstn,

    // 写端口           (Write Port)
    input               i_wen,
    input       [ 4:0]  i_waddr_5,
    input       [31:0]  i_wdata_32,

    // 读端口
    input       [ 4:0]  i_raddr1_5,
    input       [ 4:0]  i_raddr2_5,
    output      [31:0]  o_rdata1_32,
    output      [31:0]  o_rdata2_32
);
	integer i;
    reg [31:0] rf[31:0];
    always @(posedge clk or negedge rstn) begin
		if(!rstn)begin
				for (i = 0; i < 32; i=i+1) begin
					rf[i] <= 32'b0;	
				end
		end else begin
        rf[i_waddr_5]	<= {32{ i_wen}}	& i_wdata_32	
						|  {32{~i_wen}}	& rf[i_waddr_5] ;
		rf[0]			<= 32'b0;
				end
    end

    // 读端口1
    assign o_rdata1_32  = {{32{| i_raddr1_5}}   & rf[i_raddr1_5]};

     //读端口2
    assign o_rdata2_32  = {{32{| i_raddr2_5}}   & rf[i_raddr2_5]};

endmodule
