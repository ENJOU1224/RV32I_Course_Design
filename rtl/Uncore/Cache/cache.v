/*
    -- ============================================================================
    -- FILE NAME	: cache.v
    -- DESCRIPTION	: cache
    -- ----------------------------------------------------------------------------
    -- Revision		Date				Coding_by		Comment
    -- 1.0.0			2022/05/31  enjou				初版 
    -- ============================================================================
*/

module cache (
		input clk,  // 时钟信号
    input rstn, // 复位信号

    // Cache 与 CPU流水线 的交互接口
    input					i_Valid,						// 请求有效标志
    input					i_Operation,				// 读写操作标志，1为写，0为读
    input [ 7:0]	i_Index,						// 地址index域(addr[11:4])
    input [19:0]	i_Tag,							// 地址tag域	
    input [ 3:0]	i_Offset,						// 地址offset域(addr[3:0])
    input [31:0]	i_StoreData,				// 写数据
    output				o_DataOK,						// 读取情况下，返回数据有效；写入情况下，数据写入完成
    output[31:0]	o_LoadData,					// 读取数据 

    //Cache与AXI总线的交互接口
    output				o_LoadRequire,			// 读取信号
    output [ 2:0]	o_LoadWidth,				// 读取数据宽度 3'b000:字节 3'b001:半字 3'b010:字 3'b100:Cache行
    output [31:0] o_LoadAddr,					// 读地址
    input					i_LoadReady,				// 读请求接收准备好
    input					i_ReturnValid,			// 返回数据有效
    input [ 1:0]	i_ReturnLast,				// 最后一读数据
    input [31:0]	i_ReturnData,				// 返回读数据
    output				o_WriteRequire,			// 写请求信号
    output[ 2:0]	o_WriteWidth,				// 写数据宽度 3'b000:字节 3'b001:半字 3'b010:字 3'b100:Cache行
    output[31:0]	o_WriteAddr,				// 写地址
    output[ 3:0]	o_WriteByteEnable,  // 写字节掩码
    output[127:0] o_WriteData,				// 写数据
    input					i_WriteReady				// 写允许
);

  //--------------------- 物理地址暂存buffer --------------------//	

  reg [31:0]	PhysicalAddr;
	wire[19:0]	InputTag;
	wire[ 7:0]	InputIndex;
	wire[ 3:0]	InputOffset;

	assign InputTag		= PhysicalAddr[31:12];
	assign InputIndex	= PhysicalAddr[11: 4];
	assign InputOffset= PhysicalAddr[ 3: 0];

  always @(posedge clk or negedge rstn) begin

    if (!rstn) begin
      PhysicalAddr <= 32'b0;
    end else begin
      PhysicalAddr <= {i_Tag, i_Index, i_Offset};
    end

  end

  //--------------------- Hit判断部分 --------------------//	

	wire WAY0Hit;
	wire WAY1Hit;
	wire CacheHit;

	assign WAY0Hit = WAY0Valid && (InputTag == WAY0TAG);
	assign WAY1Hit = WAY1Valid && (InputTag == WAY1TAG);
	assign CacheHit= WAY0Hit | WAY1Hit;

  //--------------------- 使能信号 --------------------//	
	
	// 使能信号
	wire[3:0] BankEnable;
	wire[3:0] ByteWriteEnable;

	// Bank使能信号生成
	assign BankEnable[3]		= i_Offset[3:2] == 3 && i_Valid;
	assign BankEnable[2]		= i_Offset[3:2] == 2 && i_Valid;
	assign BankEnable[1]		= i_Offset[3:2] == 1 && i_Valid;
	assign BankEnable[0]		= i_Offset[3:2] == 0 && i_Valid;

	// 字节写使能信号
	assign ByteWriteEnable[3]		= i_Offset[3:2] == 3 && i_Operation;
	assign ByteWriteEnable[2]		= i_Offset[3:2] == 2 && i_Operation;
	assign ByteWriteEnable[1]		= i_Offset[3:2] == 1 && i_Operation;
	assign ByteWriteEnable[0]		= i_Offset[3:2] == 0 && i_Operation;

  //--------------------- 输入输出处理部分 --------------------//	
	assign o_LoadData	= {32{WAY0Hit}}	& WAY0ReadData
										| {32{WAY1Hit}}	& WAY1ReadData;

	assign o_DataOK		= {i_Operation} & CacheHit;

  //--------------------- Cache WAY 0 --------------------//	
	
	
	// TAGV_RAM
	wire[20:0]	WAY0TAGV;
	wire[19:0]	WAY0TAG;
	wire				WAY0Valid;	

	assign {WAY0TAG,WAY0Valid}	= WAY0TAGV;

  TAGV_RAM TAGV_WAY0_RAM (
      .clka		(clk				),	// input wire clka
      .ena		(ena				),  // input wire ena
      .wea		(wea				),  // input wire [0 : 0] wea
      .addra	(i_Index		),  // input wire [7 : 0] addra
      .dina		(WriteTAGV	),  // input wire [20 : 0] dina
      .douta	(WAY0TAGV		)		// output wire [20 : 0] douta
  );

	// DirtyReg
	reg[255:0]	WAY0_DirtyReg;
	wire WAY0DirtyReg_Next;

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			WAY0_DirtyReg <= 256'b0;
		end	else begin
			WAY0_DirtyReg[i_Index] <= WAY0DirtyReg_Next;
		end
	end

	// DATA_Bank_RAM
	wire[127:0]	WAY0CacheReadData;
	wire[31:0]	WAY0ReadData;

	assign WAY0ReadData		= WAY0CacheReadData[127:96]
												| WAY0CacheReadData[ 95:64]
												| WAY0CacheReadData[ 63:32]
												| WAY0CacheReadData[ 31: 0];

  DATA_Bank_RAM DATA_Bank_WAY0_RAM0 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[3]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[127-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY0_RAM1 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[2]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[ 95-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY0_RAM2 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[1]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[ 63-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY0_RAM3 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[0]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[ 31-:32]	)   // output wire [31 : 0] douta
  );

  //--------------------- Cache Way 1 --------------------//	
	//TAGV_RAM
	wire[20:0]	WAY1TAGV;
	wire[19:0]	WAY1TAG;
	wire				WAY1Valid;

	assign {WAY1TAG,WAY1Valid}	= WAY1TAGV;

  TAGV_RAM TAGV_WAY1_RAM (
      .clka		(clk			),  // input wire clka
      .ena		(ena			),  // input wire ena
      .wea		(wea			),  // input wire [0 : 0] wea
      .addra	(i_Index	),	// input wire [7 : 0] addra
      .dina		(dina			),  // input wire [20 : 0] dina
      .douta	(WAY1TAGV	)   // output wire [20 : 0] douta
  );

	// DirtyReg
	reg[255:0] WAY1_DirtyReg;
	wire WAY1DirtyReg_Next;

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			WAY1_DirtyReg <= 256'b0;
		end	else begin
			WAY1_DirtyReg[i_Index] <= WAY1DirtyReg_Next;
		end
	end
	//DATA_Bank_RAM
	wire[127:0]	WAY1CacheReadData;
	wire[31:0]	WAY1ReadData;

	assign WAY1ReadData		= WAY1CacheReadData[127:96]
												| WAY1CacheReadData[ 95:64]
												| WAY1CacheReadData[ 63:32]
												| WAY1CacheReadData[ 31: 0];

  DATA_Bank_RAM DATA_Bank_WAY1_RAM0 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[3]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[127-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY1_RAM1 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[2]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[ 95-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY1_RAM2 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[1]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[ 63-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY1_RAM3 (
      .clka		(clk												),  // input wire clka
      .ena		(BankEnable[0]							),  // input wire ena
      .wea		(wea												),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(dina												),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[ 31-:32]	)   // output wire [31 : 0] douta
  );

endmodule
