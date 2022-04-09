module CarryGen(
	input [3:0]		p,
	input [3:0]		g,
	input			cin,
	output[3:0]		c,
	output			cout
);

	assign c[0]	= cin;
	assign c[1]	= g[0]	| c[0]&p[0];
	assign c[2]	= g[1]	| g[0]&p[1]	| c[0]&p[1]&p[0];
	assign c[3]	= g[2]	| g[1]&p[2]	| g[0]&p[2]&p[1]| c[0]&p[2]&p[1]&p[0];
	assign cout	= g[3]	| g[2]&p[3] | g[1]&p[3]&p[2]| g[0]&p[3]&p[2]&p[1]	| c[0]&p[3]&p[2]&p[1]&p[0];
																				
endmodule
