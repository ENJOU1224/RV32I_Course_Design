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
    input [ 1:0]	i_ReturnOffset,			// 最后一读数据
    input [31:0]	i_ReturnData,				// 返回读数据
    output				o_StoreRequire,			// 写请求信号
    output[ 2:0]	o_StoreWidth,				// 写数据宽度 3'b000:字节 3'b001:半字 3'b010:字 3'b100:Cache行
    output[31:0]	o_StoreAddr,				// 写地址
    output[ 3:0]	o_StoreByteEnable,  // 写字节掩码
    output[127:0] o_StoreData,				// 写数据
    input					i_StoreReady				// 写允许
);

  //--------------------- Cache模块主状态机 --------------------//	
	reg [2:0]	CacheState;								// Cache状态，3'b000:IDLE 3'b001:LOOKUP 3'b011:MISS 3'b010:REPLACE 3'b110:REFILL
	reg				WriteBufferState;					// WriteBuffer状态 1'b0:IDLE 1'b1:WRITE
	wire[2:0] CacheStateNext;						// Cache下一周期状态
	wire HitWriteLookUpConflict;

	assign HitWriteLookUpConflict = i_Offset[3:2] == InputOffset[3:2];

												//-----Cache当前状态-----//		//---------------状态切换条件---------------//		//下一状态				// Cache当前状态								// 状态切换条件																					// Cache下一状态	
	assign CacheStateNext = {3{CacheState == 3'b000}} &({3{HitWriteLookUpConflict | ~i_Valid						}} & 3'b000					// 当前Cache State为IDLE		时	，若 无 输入或输入 与		Hit Write冲突										，则下一状态仍为IDLE
																										| {3{i_Valid & ~HitWriteLookUpConflict						}} & 3'b001)				// 当前Cache State为IDLE		时	，若 有 输入且输入 不与 Hit Write冲突										，则下一状态为Look Up
												| {3{CacheState == 3'b001}} &({3{HitWriteLookUpConflict | ~i_Valid						}} & 3'b000					// 当前Cache State为Look Up 时	，若 无 输入或输入 与		Hit Write冲突										，则下一状态为IDLE
																										| {3{i_Valid & ~HitWriteLookUpConflict & CacheHit	}} & 3'b001					// 当前Cache State为Look Up 时	，若 有 输入且输入 不与	Hit Write冲突且当前Look Up 命中 ，则下一状态为Look Up
																										| {3{~CacheHit																		}} & 3'b011)				// 当前Cache State为Look Up	时	，若 Cache未命中																				，则下一状态为MISS
												| {3{CacheState == 3'b011}} &({3{~i_StoreReady																}} & 3'b011					// 当前Cache State为MISS		时	，若 AXI总线接口反馈回来的StoreReady为0									，则下一状态仍为MISS
																										| {3{ i_StoreReady																}} & 3'b010)				// 当前Cache State为MISS		时	，若 AXI总线接口反馈回来的StoreReady为1									，则下一状态为REPLACE
												| {3{CacheState == 3'b010}} &({3{~i_LoadReady																	}} & 3'b010					// 当前Cache State为REPLACE	时	，若 AXI总线接口反馈回来的LoadReady为0									，则下一状态为REPLACE
																										| {3{ i_LoadReady																	}} & 3'b110)				// 当前Cache State为REPLACE	时	，若 AXI总线接口反馈回来的LoadReady为1									，则下一状态为REFILL
												| {3{CacheState == 3'b110}} &({3{~(i_ReturnValid & (&i_ReturnOffset))					}} & 3'b110					// 当前Cache State为REFILL	时	，若 缺失Cache行的最后一个字数据尚未返回								，则下一状态为REFILL
																										| {3{  i_ReturnValid & (&i_ReturnOffset)					}} & 3'b000);				// 当前Cache State为REFILL	时	，若 缺失Cache行的最后一个字数据返回										，则下一状态为IDLE

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			CacheState <= 3'b000;
			WriteBufferState	<= 1'b0;	
		end else begin
			CacheState <= CacheStateNext;
			WriteBufferState	<= i_Operation & CacheHit;
		end
	end

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

  //--------------------- 替换路号生成逻辑 --------------------//	
	reg ReplaceWay;

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			ReplaceWay	<= 1'b0;
		end else begin
			ReplaceWay <= ~ReplaceWay & CacheState == 3'b011;
		end
	end
  //--------------------- Hit判断部分 --------------------//	

	wire WAY0Hit;
	wire WAY1Hit;
	wire CacheHit;

	assign WAY0Hit = WAY0Valid & (InputTag == WAY0TAG);
	assign WAY1Hit = WAY1Valid & (InputTag == WAY1TAG);
	assign CacheHit= WAY0Hit | WAY1Hit;

  //--------------------- 使能信号 --------------------//	
	
	// 使能信号
	wire[3:0] WAY0BankEnable;
	wire[3:0] WAY1BankEnable;

	// WAY0Bank使能信号生成
	assign WAY0BankEnable[3]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 3 
														| CacheState == 3'b001	&(i_Operation & WAY0Hit								& InputOffset		[3:2]	== 3					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 3)					// Cache状态为LookUp Hit,准备进行下一个Lookup
														| CacheState == 3'b010	& ReplaceWay == 1'b0																											// Cache状态为REPLACE		,当前替换路为0
														| CacheState == 3'b110	& ReplaceWay == 1'b0	&	i_ReturnValid	& i_ReturnOffset[1:0] == 3;					// Cache状态为REFILL		,当前替换路为0,当前返回有效且为最高字

	assign WAY0BankEnable[2]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 2
														| CacheState == 3'b001	& (i_Operation & WAY0Hit							& InputOffset		[3:2] == 2					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 2)					// Cache状态为LookUp Hit,当前输入为Store操作，	
														| CacheState == 3'b010	& ReplaceWay == 1'b0																											// Cache状态为REPLACE		,当前替换路为0
														| CacheState == 3'b110	& ReplaceWay == 1'b0	&	i_ReturnValid	& i_ReturnOffset[1:0] == 2;					// Cache状态为REFILL		,当前替换路为0,当前返回有效且为次高字
													
	assign WAY0BankEnable[1]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 1
														| CacheState == 3'b001	&(i_Operation & WAY0Hit								& InputOffset		[3:2]	== 1					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 1)					// Cache状态为LookUp Hit,准备进行下一个Lookup
														| CacheState == 3'b010	& ReplaceWay == 1'b0																											// Cache状态为REPLACE		,当前替换路为0
														| CacheState == 3'b110	& ReplaceWay == 1'b0	&	i_ReturnValid	& i_ReturnOffset[1:0] == 1;					// Cache状态为REFILL		,当前替换路为0,当前返回有效且为次低字

	assign WAY0BankEnable[0]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 0
														| CacheState == 3'b001	&(i_Operation & WAY0Hit								& InputOffset		[3:2]	== 0					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 0)					// Cache状态为LookUp Hit,准备进行下一个Lookup
														| CacheState == 3'b010	& ReplaceWay == 1'b0																											// Cache状态为REPLACE		,当前替换路为0
														| CacheState == 3'b110	& ReplaceWay == 1'b0	&	i_ReturnValid	& i_ReturnOffset[1:0] == 0;					// Cache状态为REFILL		,当前替换路为0,当前返回有效且为最低字

	// WAY1Bank使能信号生成
	assign WAY1BankEnable[3]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 3 
														| CacheState == 3'b001	&(i_Operation & WAY1Hit								& InputOffset		[3:2]	== 3					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 3)					// Cache状态为LookUp Hit,准备进行下一个Lookup
														| CacheState == 3'b010	& ReplaceWay == 1'b1																											// Cache状态为REPLACE		,当前替换路为1
														| CacheState == 3'b110	& ReplaceWay == 1'b1	&	i_ReturnValid	& i_ReturnOffset[1:0] == 3;					// Cache状态为REFILL		,当前替换路为1,当前返回有效且为最高字

	assign WAY1BankEnable[2]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 2
														| CacheState == 3'b001	& (i_Operation & WAY1Hit							& InputOffset		[3:2] == 2					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 2)					// Cache状态为LookUp Hit,当前输入为Store操作，	
														| CacheState == 3'b010	& ReplaceWay == 1'b1																											// Cache状态为REPLACE		,当前替换路为1
														| CacheState == 3'b110	& ReplaceWay == 1'b1	&	i_ReturnValid	& i_ReturnOffset[1:0] == 2;					// Cache状态为REFILL		,当前替换路为1,当前返回有效且为次高字
													
	assign WAY1BankEnable[1]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 1
														| CacheState == 3'b001	&(i_Operation & WAY1Hit								& InputOffset		[3:2]	== 1					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 1)					// Cache状态为LookUp Hit,准备进行下一个Lookup
														| CacheState == 3'b010	& ReplaceWay == 1'b1																											// Cache状态为REPLACE		,当前替换路为1
														| CacheState == 3'b110	& ReplaceWay == 1'b1	&	i_ReturnValid	& i_ReturnOffset[1:0] == 1;					// Cache状态为REFILL		,当前替换路为1,当前返回有效且为次低字

	assign WAY1BankEnable[0]	= CacheState == 3'b000	& i_Valid															& i_Offset			[3:2] == 0
														| CacheState == 3'b001	&(i_Operation & WAY1Hit								& InputOffset		[3:2]	== 0					// Cache状态为LookUp Hit,当前输入为Store操作，
																										|	i_Valid															& i_Offset			[3:2] == 0)					// Cache状态为LookUp Hit,准备进行下一个Lookup
														| CacheState == 3'b010	& ReplaceWay == 1'b1																											// Cache状态为REPLACE		,当前替换路为1
														| CacheState == 3'b110	& ReplaceWay == 1'b1	&	i_ReturnValid	& i_ReturnOffset[1:0] == 0;					// Cache状态为REFILL		,当前替换路为1,当前返回有效且为最低字
	
  // TAGV_RAM使能 
	wire WAY0TAGVEnable;
	wire WAY1TAGVEnable;

	assign WAY0TAGVEnable = CacheState == 3'b000 & i_Valid
												| CacheState == 3'b001 & i_Valid & ~HitWriteLookUpConflict
												| CacheState == 3'b011 & i_Valid 
												| CacheState == 3'b010 & ReplaceWay == 1'b0
												| CacheState == 3'b110 & ReplaceWay == 1'b0;
										
	assign WAY1TAGVEnable = CacheState == 3'b000 & i_Valid
												| CacheState == 3'b001 & i_Valid & ~HitWriteLookUpConflict
												| CacheState == 3'b011 & i_Valid 
												| CacheState == 3'b010 & ReplaceWay == 1'b1
												| CacheState == 3'b110 & ReplaceWay == 1'b1;
  // TAGV_RAM写使能 
	wire [1:0]	TAGVWriteEnable;
	
	assign TAGVWriteEnable[1]		= CacheState == 3'b001 & WAY1Hit 
															| CacheState == 3'b110 & ReplaceWay == 1'b1;
	
	assign TAGVWriteEnable[1]		= CacheState == 3'b001 & WAY0Hit 
															| CacheState == 3'b110 & ReplaceWay == 1'b0;

  // 字节写使能偏移译码 
	wire [3:0] WAY0ByteWriteEnable;
	wire [3:0] WAY1ByteWriteEnable;
	
	assign WAY0ByteWriteEnable[3] = CacheState == 3'b001 & i_Operation		& WAY0Hit							& InputOffset		[1:0] == 2'b11
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b0	& i_ReturnOffset[1:0] == 2'b11;
	assign WAY0ByteWriteEnable[2] = CacheState == 3'b001 & i_Operation		& WAY0Hit							& InputOffset		[1:0] == 2'b10
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b0	& i_ReturnOffset[1:0] == 2'b10;
	assign WAY0ByteWriteEnable[1] = CacheState == 3'b001 & i_Operation		& WAY0Hit							& InputOffset		[1:0] == 2'b01
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b0	& i_ReturnOffset[1:0] == 2'b01;
	assign WAY0ByteWriteEnable[0] = CacheState == 3'b001 & i_Operation		& WAY0Hit							& InputOffset		[1:0] == 2'b00
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b0	& i_ReturnOffset[1:0] == 2'b00;

	assign WAY1ByteWriteEnable[3] = CacheState == 3'b001 & i_Operation		& WAY1Hit							& InputOffset		[1:0] == 2'b11
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b1	& i_ReturnOffset[1:0] == 2'b11;
	assign WAY1ByteWriteEnable[2] = CacheState == 3'b001 & i_Operation		& WAY1Hit							& InputOffset		[1:0] == 2'b10
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b1	& i_ReturnOffset[1:0] == 2'b10;
	assign WAY1ByteWriteEnable[1] = CacheState == 3'b001 & i_Operation		& WAY1Hit							& InputOffset		[1:0] == 2'b01
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b1	& i_ReturnOffset[1:0] == 2'b01;
	assign WAY1ByteWriteEnable[0] = CacheState == 3'b001 & i_Operation		& WAY1Hit							& InputOffset		[1:0] == 2'b00
																| CacheState == 3'b110 & i_ReturnValid	& ReplaceWay == 1'b1	& i_ReturnOffset[1:0] == 2'b00;

  //--------------------- 字节写使能偏移译码 --------------------//	
	wire [31:0] CacheWriteData;

	assign CacheWriteData = {32{CacheState == 3'b001}} & i_StoreData
												| {32{CacheState == 3'b110}} & i_ReturnData;

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
      .clka		(clk						),	// input wire clka
      .ena		(WAY0TAGVEnable	),  // input wire ena
      .wea		(wea						),  // input wire [0 : 0] wea
      .addra	(i_Index				),  // input wire [7 : 0] addra
      .dina		(WriteTAGV			),  // input wire [20 : 0] dina
      .douta	(WAY0TAGV				)		// output wire [20 : 0] douta
  );

	// DirtyReg
	reg[255:0]	WAY0_DirtyReg;
	wire WAY0DirtyReg_Next;

	assign WAY0DirtyReg_Next	= CacheState == 3'b000 & WAY0_DirtyReg[InputIndex]
														| CacheState == 3'b001 & |WAY0ByteWriteEnable & WAY0Hit
														| CacheState == 3'b011 & WAY0_DirtyReg[InputIndex]
														| CacheState == 3'b010 & WAY0_DirtyReg[InputIndex]
														| CacheState == 3'b110 &  ReplaceWay == 1'b1	& 1'b0;
	

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			WAY0_DirtyReg <= 256'b0;
		end	else begin
			WAY0_DirtyReg[InputIndex] <= WAY0DirtyReg_Next;
		end
	end

	// DATA_Bank_RAM
	wire[127:0]	WAY0CacheReadData;
	wire[31:0]	WAY0ReadData;

	assign WAY0ReadData		= WAY0CacheReadData[127:96]
												| WAY0CacheReadData[ 95:64]
												| WAY0CacheReadData[ 63:32]
												| WAY0CacheReadData[ 31: 0];

  DATA_Bank_RAM DATA_Bank_WAY0_RAM3 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY0BankEnable[3]					),  // input wire ena
      .wea		(WAY0ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[127-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY0_RAM2 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY0BankEnable[2]					),  // input wire ena
      .wea		(WAY0ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[ 95-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY0_RAM1 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY0BankEnable[1]					),  // input wire ena
      .wea		(WAY0ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[ 63-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY0_RAM0 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY0BankEnable[0]					),  // input wire ena
      .wea		(WAY0ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY0CacheReadData[ 31-:32]	)   // output wire [31 : 0] douta
  );

  //--------------------- Cache Way 1 --------------------//	
	//TAGV_RAM
	wire[20:0]	WAY1TAGV;
	wire[19:0]	WAY1TAG;
	wire				WAY1Valid;

	assign {WAY1TAG,WAY1Valid}	= WAY1TAGV;

  TAGV_RAM TAGV_WAY1_RAM (
      .clka		(clk						),  // input wire clka
      .ena		(WAY1TAGVEnable	),  // input wire ena
      .wea		(wea						),  // input wire [0 : 0] wea
      .addra	(i_Index				),	// input wire [7 : 0] addra
      .dina		(dina						),  // input wire [20 : 0] dina
      .douta	(WAY1TAGV				)   // output wire [20 : 0] douta
  );

	// DirtyReg
	reg[255:0] WAY1_DirtyReg;
	wire WAY1DirtyReg_Next;

	assign WAY1DirtyReg_Next	= CacheState == 3'b001 & |WAY1ByteWriteEnable & WAY1Hit
														| CacheState == 3'b110 &  ReplaceWay == 1'b1	& 1'b0;
	
	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			WAY1_DirtyReg <= 256'b0;
		end	else begin
			WAY1_DirtyReg[InputIndex] <= WAY1DirtyReg_Next;
		end
	end
	//DATA_Bank_RAM
	wire[127:0]	WAY1CacheReadData;
	wire[31:0]	WAY1ReadData;

	assign WAY1ReadData		= WAY1CacheReadData[127:96]
												| WAY1CacheReadData[ 95:64]
												| WAY1CacheReadData[ 63:32]
												| WAY1CacheReadData[ 31: 0];

  DATA_Bank_RAM DATA_Bank_WAY1_RAM3 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY1BankEnable[3]					),  // input wire ena
      .wea		(WAY1ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[127-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY1_RAM2 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY1BankEnable[2]					),  // input wire ena
      .wea		(WAY1ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[ 95-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY1_RAM1 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY1BankEnable[1]					),  // input wire ena
      .wea		(WAY1ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[ 63-:32]	)   // output wire [31 : 0] douta
  );

  DATA_Bank_RAM DATA_Bank_WAY1_RAM0 (
      .clka		(clk												),  // input wire clka
      .ena		(WAY1BankEnable[0]					),  // input wire ena
      .wea		(WAY1ByteWriteEnable				),  // input wire [3 : 0] wea
      .addra	(i_Index										),	// input wire [7 : 0] addra
      .dina		(CacheWriteData							),  // input wire [31 : 0] dina
      .douta	(WAY1CacheReadData[ 31-:32]	)   // output wire [31 : 0] douta
  );

endmodule
