module pgGen(
	input	a,
	input	b,
	output	p,
	output	g
);
	assign p = a^b;
	assign g = a&b;
endmodule
