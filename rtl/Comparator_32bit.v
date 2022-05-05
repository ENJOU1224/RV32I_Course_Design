`timescale 1ns / 1ps

module Comparator_32bit( 
						input [31:0] m,
						input [31:0] n,
						input  equal,
						output result
										);

   wire[31:0] s_temp;
   wire[31:0] out;
   
   assign s_temp[31] = m[31]^n[31];
   assign s_temp[30] = m[30]^n[30];
   assign s_temp[29] = m[29]^n[29];
   assign s_temp[28] = m[28]^n[28];
   assign s_temp[27] = m[27]^n[27];
   assign s_temp[26] = m[26]^n[26];
   assign s_temp[25] = m[25]^n[25];
   assign s_temp[24] = m[24]^n[24];
   assign s_temp[23] = m[23]^n[23];
   assign s_temp[22] = m[22]^n[22];
   assign s_temp[21] = m[21]^n[21];
   assign s_temp[20] = m[20]^n[20];
   assign s_temp[19] = m[19]^n[19];
   assign s_temp[18] = m[18]^n[18];
   assign s_temp[17] = m[17]^n[17];
   assign s_temp[16] = m[16]^n[16];
   assign s_temp[15] = m[15]^n[15];
   assign s_temp[14] = m[14]^n[14];
   assign s_temp[13] = m[13]^n[13];
   assign s_temp[12] = m[12]^n[12];
   assign s_temp[11] = m[11]^n[11];
   assign s_temp[10] = m[10]^n[10];
   assign s_temp[9] = m[9]^n[9];
   assign s_temp[8] = m[8]^n[8];
   assign s_temp[7] = m[7]^n[7];
   assign s_temp[6] = m[6]^n[6];
   assign s_temp[5] = m[5]^n[5];
   assign s_temp[4] = m[4]^n[4];
   assign s_temp[3] = m[3]^n[3];
   assign s_temp[2] = m[2]^n[2];
   assign s_temp[1] = m[1]^n[1];
   assign s_temp[0] = m[0]^n[0];
   
   selector_2bit d31(m[31],out[30],s_temp[31],out[31]);
   selector_2bit d30(m[30],out[29],s_temp[30],out[30]);
   selector_2bit d29(m[29],out[28],s_temp[29],out[29]);
   selector_2bit d28(m[28],out[27],s_temp[28],out[28]);
   selector_2bit d27(m[27],out[26],s_temp[27],out[27]);
   selector_2bit d26(m[26],out[25],s_temp[26],out[26]);
   selector_2bit d25(m[25],out[24],s_temp[25],out[25]);
   selector_2bit d24(m[24],out[23],s_temp[24],out[24]);
   selector_2bit d23(m[23],out[22],s_temp[23],out[23]);
   selector_2bit d22(m[22],out[21],s_temp[22],out[22]);
   selector_2bit d21(m[21],out[20],s_temp[21],out[21]);
   selector_2bit d20(m[20],out[19],s_temp[20],out[20]);
   selector_2bit d19(m[19],out[18],s_temp[19],out[19]);
   selector_2bit d18(m[18],out[17],s_temp[18],out[18]);
   selector_2bit d17(m[17],out[16],s_temp[17],out[17]);
   selector_2bit d16(m[16],out[15],s_temp[16],out[16]);
   selector_2bit d15(m[15],out[14],s_temp[15],out[15]);
   selector_2bit d14(m[14],out[13],s_temp[14],out[14]);
   selector_2bit d13(m[13],out[12],s_temp[13],out[13]);
   selector_2bit d12(m[12],out[11],s_temp[12],out[12]);
   selector_2bit d11(m[11],out[10],s_temp[11],out[11]);
   selector_2bit d10(m[10],out[9],s_temp[10],out[10]);
   selector_2bit d9(m[9],out[8],s_temp[9],out[9]);
   selector_2bit d8(m[8],out[7],s_temp[8],out[8]);
   selector_2bit d7(m[7],out[6],s_temp[7],out[7]);
   selector_2bit d6(m[6],out[5],s_temp[6],out[6]);
   selector_2bit d5(m[5],out[4],s_temp[5],out[5]);
   selector_2bit d4(m[4],out[3],s_temp[4],out[4]);
   selector_2bit d3(m[3],out[2],s_temp[3],out[3]);
   selector_2bit d2(m[2],out[1],s_temp[2],out[2]);
   selector_2bit d1(m[1],out[0],s_temp[1],out[1]);
   selector_2bit d0(m[0],equal,s_temp[0],out[0]);
   
   assign result = out[31];

endmodule
