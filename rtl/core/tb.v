`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2022 03:17:43 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb(

    );
 reg clk;
 reg rstn;
cpu_top cpu_top(
    .clk    (clk),
    .rstn   (rstn)
    );
    initial begin
        clk = 1;
        rstn= 0;
     #100
        rstn= 1;
    end
    always #10 clk = ~clk;
endmodule
