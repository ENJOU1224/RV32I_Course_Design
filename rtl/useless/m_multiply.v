`timescale 1ns / 1ps
module m_multiply(                         
    input               clk,
    input               rstn,
    input               i_mulBegin_1,       
    input        [31:0] i_mulOperand1_32,   
    input        [31:0] i_mulOperand2_32,
    input        [ 1:0] i_mulDivSign_2,
    output       [63:0] o_product_64,
    output              o_mulWorking_1,
    output              o_mulEnd_1
);

    reg [3:0] r_cnt_4;
    wire [3:0] w_cntNext_4;

    reg [63:0] r_product_64;
    wire [63:0] w_product_64;
    wire [3:0] w_partOperand_4;
    wire [35:0] w_partProduct_36;

    wire [31:0] w_operand1_32;
    wire [31:0] w_operand2_32;

    wire w_productNeg_1;

    wire w_cntEqu8_1;
    
    assign w_productNeg_1   = i_mulDivSign_2[0] & i_mulOperand1_32[31] & ~(i_mulDivSign_2[1] & i_mulOperand2_32[31])
                            | i_mulDivSign_2[1] & i_mulOperand2_32[31] & ~(i_mulDivSign_2[0] & i_mulOperand1_32[31]);
    assign w_cntEqu8_1      = r_cnt_4[3]&~|r_cnt_4[2:0];

    assign w_operand1_32    = {32{  i_mulDivSign_2[1] & i_mulOperand1_32[31] }} & ~i_mulOperand1_32+1'b1
                            | {32{~(i_mulDivSign_2[1] & i_mulOperand1_32[31])}} &  i_mulOperand1_32;

    assign w_operand2_32    = {32{  i_mulDivSign_2[0] & i_mulOperand2_32[31] }} & ~i_mulOperand2_32+1'b1
                            | {32{~(i_mulDivSign_2[0] & i_mulOperand2_32[31])}} &  i_mulOperand2_32;

    assign w_cntNext_4 =  {4{w_cntEqu8_1                    }} & 4'b0
                        | {4{i_mulBegin_1 & ~w_cntEqu8_1    }} & r_cnt_4+1;

    assign w_partOperand_4  = {4{~|r_cnt_4[3:1] &  r_cnt_4[0]                       }} & w_operand2_32[31:28]
                            | {4{~|r_cnt_4[3:2] & r_cnt_4[1] & ~r_cnt_4[0]          }} & w_operand2_32[27:24]
                            | {4{~|r_cnt_4[3:2] & &r_cnt_4[1:0]                     }} & w_operand2_32[23:20]
                            | {4{~ r_cnt_4[3]   & r_cnt_4[2]&~|r_cnt_4[1:0]         }} & w_operand2_32[19:16]
                            | {4{~ r_cnt_4[3]   & r_cnt_4[2]&~r_cnt_4[1]& r_cnt_4[0]}} & w_operand2_32[15:12]
                            | {4{~ r_cnt_4[3]   & r_cnt_4[2]& r_cnt_4[1]&~r_cnt_4[0]}} & w_operand2_32[11: 8]
                            | {4{~ r_cnt_4[3]   & &r_cnt_4[2:0]                     }} & w_operand2_32[ 7: 4]
                            | {4{  r_cnt_4[3]   & ~|r_cnt_4[2:0]                    }} & w_operand2_32[ 3: 0];


    assign w_partProduct_36 = w_operand1_32 * w_partOperand_4;

    m_adder m_adder(
		.i_adderOperand1_64 ({28'b0,w_partProduct_36}	),
		.i_adderOperand2_64 ({r_product_64[59:0],4'b0}	),
		.i_cIn_1	    	(1'b0						),
		.o_adderSum_64	    (w_product_64				),
		.o_cOut_1	    	(							)
		);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            r_cnt_4 = 4'b0;
            r_product_64 = 64'b0;
        end else begin
            r_cnt_4 = w_cntNext_4;
            r_product_64 = w_product_64 &{64{~o_mulEnd_1}};
        end
    end
    assign o_product_64 = {64{ w_productNeg_1}}   & ~w_product_64+1
                        | {64{~w_productNeg_1}}   &  w_product_64;
    assign o_mulWorking_1 = (|r_cnt_4 | i_mulBegin_1)&rstn;
    assign o_mulEnd_1 = ~o_mulWorking_1|w_cntEqu8_1;
	
    endmodule

