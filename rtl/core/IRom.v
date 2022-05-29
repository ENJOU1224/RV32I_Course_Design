module IRom (
    input       [31:0]  addr,       // 指令地址
    output reg  [31:0]  inst        // 指令
);

    reg [31:0] inst_rom[31:0];     // 指令存储器,字节地址7'b000_0000~7'b111_1111

	initial $readmemh("~/work/assignment/rtl/1.txt", inst_rom);

    // 读指令,取4字节
    always @(*) begin
		inst = inst_rom[addr];	
    end
endmodule
