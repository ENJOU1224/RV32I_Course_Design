//-----------------------------------------------
//    module name: 
//    author: Wei Ren
//  
//    version: 1st version (2021-10-01)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps

module m_division(
    input             clk,
    input             rstn,
    input             i_divBegin_1,
    input [1:0]     i_mulDivSign_2,
    input [31:0]    i_divOperand1_32,
    input [31:0]    i_divOperand2_32,
    output [31:0]   o_quotient_32,
    output [31:0]   o_remainder_32,
    output             o_divWorking_1,
    output             o_divEnd_1
);

  reg [5:0] cnt;
  wire [5:0] cnt_next;
  reg  r_divEnd_1;
  reg [63:0] x_,y_,y1, y2, y3,y4,y5,y6,y7,y8,y9,yA,yB,yC,yD,yE,yF;
  reg [31:0] quot; // quotient
  reg sign_s, sign_r;
  wire div_signed = i_mulDivSign_2[0];
  wire [31:0] xx = (i_divOperand1_32[31]&&div_signed) ? ~i_divOperand1_32+1'b1:i_divOperand1_32;
  wire [31:0] yx = (i_divOperand2_32[31]&&div_signed) ? ~i_divOperand2_32+1'b1:i_divOperand2_32;
  wire [63:0] y1_wire = {4'd0, yx, 28'd0};
  wire [64:0] sub1_res;
  wire [64:0] sub2_res;
  wire [64:0] sub3_res;
  wire [64:0] sub4_res;
  wire [64:0] sub5_res;
  wire [64:0] sub6_res;
  wire [64:0] sub7_res;
  wire [64:0] sub8_res;
  wire [64:0] sub9_res;
  wire [64:0] subA_res;
  wire [64:0] subB_res;
  wire [64:0] subC_res;
  wire [64:0] subD_res;
  wire [64:0] subE_res;
  wire [64:0] subF_res;
  wire working = cnt != 6'd0;
  wire cresult;

  assign cnt_next =(i_divBegin_1 && ((!cresult)||(~(|i_divOperand2_32))))?9:(o_divEnd_1?0:cnt+((i_divBegin_1)? 6'd1: (cnt+(working ?6'd1: 6'd0))));
  always @(posedge clk or negedge rstn) begin
    if (!rstn) cnt <= 6'd0;
    else cnt <= cnt_next;
  end
  Comparator_8bit_1 c1(xx,yx,cresult);
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin 
      x_ <= 64'd0;
      y1 <= 64'd0;
      y2 <= 64'd0;
      y3 <= 64'd0;
      quot <= 32'd0;
      sign_s <= 1'b0;
      sign_r <= 1'b0;
    end
    else 
    if(!cresult) begin
    quot <= sign_s ? ~0+1'b1 : 0;
    x_ <= i_divOperand1_32;
    end 
    else
    if (cnt_next == 6'd1) begin
      x_ <= {32'd0, xx};
      y1 <= y1_wire;                                        //0001
      y2 <= y1_wire << 1;                                   //0010
      y3 <= y1_wire + (y1_wire << 1);                       //0011
      y4 <= y1_wire << 2;                                   //0100
      y5 <= y1_wire + (y1_wire << 2);                       //0101
      y6 <= (y1_wire << 1)+ (y1_wire << 2);                 //0110
      y7 <= y1_wire + (y1_wire << 1)+(y1_wire << 2);        //0111
      y8 <= y1_wire <<3;                                    //1000
      y9 <= y1_wire + (y1_wire << 3);                       //1001
      yA <= (y1_wire << 1) + (y1_wire << 3);               //1010
      yB <= y1_wire + (y1_wire << 1) + (y1_wire << 3);     //1011
      yC <= (y1_wire << 2) + (y1_wire << 3);               //1100
      yD <= y1_wire + (y1_wire << 2) + (y1_wire << 3);     //1101
      yE <= (y1_wire << 1) + (y1_wire << 2) + (y1_wire << 3);              //1110
      yF <= y1_wire + (y1_wire << 1) + (y1_wire << 2) + (y1_wire << 3);    //1111
      sign_s <= (i_divOperand1_32[31]^i_divOperand2_32[31]) && div_signed;
      sign_r <= i_divOperand1_32[31] && div_signed;
    end
    else if (cnt != 6'd9) begin
      x_ <= !subF_res[64] ? subF_res[63:0]
          : !subE_res[64] ? subE_res[63:0]
          : !subD_res[64] ? subD_res[63:0]
          : !subC_res[64] ? subC_res[63:0]
          : !subB_res[64] ? subB_res[63:0]
          : !subA_res[64] ? subA_res[63:0]
          : !sub9_res[64] ? sub9_res[63:0]
          : !sub8_res[64] ? sub8_res[63:0]
          : !sub7_res[64] ? sub7_res[63:0]
          : !sub6_res[64] ? sub6_res[63:0]
          : !sub5_res[64] ? sub5_res[63:0]
          : !sub5_res[64] ? sub5_res[63:0]
          : !sub4_res[64] ? sub4_res[63:0]
          : !sub3_res[64] ? sub3_res[63:0]
          : !sub2_res[64] ? sub2_res[63:0]
          : !sub1_res[64] ? sub1_res[63:0]
          : x_;
      y1 <= y1 >> 4;
      y2 <= y2 >> 4;
      y3 <= y3 >> 4;
      y4 <= y4 >> 4;
      y5 <= y5 >> 4;
      y6 <= y6 >> 4;
      y7 <= y7 >> 4;
      y8 <= y8 >> 4;
      y9 <= y9 >> 4;
      yA <= yA >> 4;
      yB <= yB >> 4;
      yC <= yC >> 4;
      yD <= yD >> 4;
      yE <= yE >> 4;
      yF <= yF >> 4;
      quot <= (quot << 4) | {28'd0,!subF_res[64] ? 4'HF
                                  :!subE_res[64] ? 4'HE 
                                  :!subD_res[64] ? 4'HD 
                                  :!subC_res[64] ? 4'HC 
                                  :!subB_res[64] ? 4'HB
                                  :!subA_res[64] ? 4'HA 
                                  :!sub9_res[64] ? 4'H9 
                                  :!sub8_res[64] ? 4'H8 
                                  :!sub7_res[64] ? 4'H7 
                                  :!sub6_res[64] ? 4'H6 
                                  :!sub5_res[64] ? 4'H5 
                                  :!sub4_res[64] ? 4'H4 
                                  :!sub3_res[64] ? 4'H3 
                                  :!sub2_res[64] ? 4'H2 
                                  :!sub1_res[64] ? 4'H1 
                                  :4'd0};
    end
  end
    
    wire [31:0] w_signedQuotient_32;
    wire [31:0] w_signedRemainder_32;
  assign w_signedQuotient_32  = !cresult  ? 0:sign_s ? ~quot+1'b1 : quot;
  assign w_signedRemainder_32 = sign_r    ? ~x_[31:0]+1'b1  : x_[31:0];
    assign o_quotient_32        = {{32{~|i_divOperand2_32}}    & {32'hFFFFFFFF                }}
                                | {{32{ |i_divOperand2_32}}    & {w_signedQuotient_32  }};

    assign o_remainder_32       = {{32{~|i_divOperand2_32}}    & {i_divOperand1_32        }}
                                | {{32{ |i_divOperand2_32}}    & {w_signedRemainder_32    }};

  assign o_divEnd_1            = cnt == 6'd9 |(!(|cnt) & !i_divBegin_1);
  assign o_divWorking_1        = working;
endmodule
