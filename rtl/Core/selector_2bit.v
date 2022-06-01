//-----------------------------------------------
//    module name: 
//    author: WeiRen
//  
//    version: 1st version (2021-10-01)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps

module selector_2bit(
						input a,
						input b,
						input s,
						output out
									);
    
    assign out	= s&a
				|~s&b;
 endmodule
