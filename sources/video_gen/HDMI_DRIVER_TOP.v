


// 把 HDMI_MODE_SEL 传给 hdmi_driver。可选 "640x480@60"、"1280x720@60"、"1920x1080@30"、"1920x1080@60"。
// 1080p30 与 1080p60 行场相同：H 2200/44/88/148/1920，V 1125/5/4/36/1080。像素时钟 74.25 MHz。
module HDMI_DRIVER_TOP #(
    parameter [127:0]           HDMI_MODE_SEL = "1920x1080@60"
)(
    input   wire                HDMI_CLK            ,  
    input   wire                RESET               ,
  
    input   wire                HDMI_INIT_DONE      ,
    input   wire                HDMI_BLACK_LOCKED   ,

    input   wire    [12:0]      HDMI_VALID_WIDTH    ,
    input   wire    [12:0]      HDMI_VALID_HEIGHT   ,

    input   wire                SDRAM_CLK           ,
    input   wire                SDRAM_P1_DV         ,
    input   wire    [23:0]      SDRAM_P1_DATA       ,
    input   wire                SDRAM_P2_DV         ,
    input   wire    [23:0]      SDRAM_P2_DATA       ,

    output  wire                HDMI_BUFFER1_REQ    ,
    input   wire                HDMI_FRAMER1_DONE   ,
    output  wire                HDMI_BUFFER2_REQ    ,
    input   wire                HDMI_FRAMER2_DONE   ,

    output  wire                O_HDMI_VSYNC        , 
    output  wire                O_HDMI_HSYNC        , 
    output  wire                O_HDMI_DE           , 
    output  wire    [12:0]      O_HDMI_XCNT         ,
    output  wire    [12:0]      O_HDMI_YCNT         ,
    output  wire    [23:0]      O_HDMI_RGB1         ,
    output  wire    [23:0]      O_HDMI_RGB2         
);

reg                             init_done_sync      = 0;
reg                             hdmi_black_sync     = 1'b0;
reg     [12:0]                  hdmi_valid_width    ;
reg     [12:0]                  hdmi_valid_height   ;

reg     [2:0]                   vsync_r3            ;
reg     [23:0]                  vsync_pos_r24       ;

wire                            soft_reset          ;
/*----------------------------------------------------------*/
reg                             asfifo1_we          ;
reg     [23:0]                  asfifo1_di          ;
wire                            asfifo1_re          ;
wire    [23:0]                  asfifo1_dout        ;
wire                            asfifo1_full_flag   ;
wire                            asfifo1_empty_flag  ;
wire    [10:0]                  asfifo1_rdusedw     ;
reg                             asfifo1_re_r        ;
/*----------------------------------------------------------*/
reg                             asfifo2_we          ;
reg     [23:0]                  asfifo2_di          ;
wire                            asfifo2_re          ;
wire    [23:0]                  asfifo2_dout        ;
wire                            asfifo2_full_flag   ;
wire                            asfifo2_empty_flag  ;
wire    [10:0]                  asfifo2_rdusedw     ;
reg                             asfifo2_re_r        ;
/*----------------------------------------------------------*/
reg                             fifo_write_start    ;
reg                             fifo_write_hold     ;

reg                             fifo1_write_req     ;
reg                             fifo2_write_req     ;

wire                            pixel_req           ;
wire    [12:0]                  pixel_xpos          ;
wire    [12:0]                  pixel_ypos          ;

wire                            head_flag           ;

reg     [12:0]                  pixel_xpos_r1       ;
reg     [12:0]                  pixel_xpos_r2       ;
reg     [12:0]                  pixel_ypos_r1       ;

reg     [23:0]                  pixel_data1         ;
reg     [23:0]                  pixel_data2         ;


always@(posedge HDMI_CLK) begin
    vsync_r3 <= {vsync_r3[1:0],O_HDMI_VSYNC};
    vsync_pos_r24 <= {vsync_pos_r24[22:0],vsync_r3[1] & !vsync_r3[2]};
end

always@(posedge HDMI_CLK) begin
    init_done_sync      <= vsync_pos_r24[2] ? HDMI_INIT_DONE    : init_done_sync    ;
    hdmi_black_sync     <= vsync_pos_r24[2] ? HDMI_BLACK_LOCKED : hdmi_black_sync   ; 

    hdmi_valid_width    <= vsync_pos_r24[2] ? HDMI_VALID_WIDTH  : hdmi_valid_width  ;
    hdmi_valid_height   <= vsync_pos_r24[2] ? HDMI_VALID_HEIGHT : hdmi_valid_height ;
end

assign soft_reset = (| vsync_pos_r24[11:0]);

always@(posedge HDMI_CLK) begin

    fifo_write_start <= head_flag;

    if(RESET) begin
        fifo_write_hold <= 1'b0;
    end
    else if(vsync_pos_r24[0]) begin
        fifo_write_hold <= 1'b0;
    end
    else if(fifo_write_start) begin
        fifo_write_hold <= 1'b1;
    end
end

always@(posedge HDMI_CLK) begin
    if(RESET | soft_reset) begin
        fifo1_write_req <= 1'b0;
    end
    // 读口一次提交整行 640 点，中途不停。水位停在 256，写完一行约 896，
    // 离深度 2048 还很远。水位靠上时会写满，11 位 rdusedw 回到 0，请求停不下来。
    else if(asfifo1_rdusedw <= 11'd256 && init_done_sync && fifo_write_hold && !HDMI_FRAMER1_DONE) begin
        fifo1_write_req <= 1'b1;
    end
    else begin
        fifo1_write_req <= 1'b0;
    end
end

always@(posedge HDMI_CLK) begin
    if(RESET | soft_reset) begin
        fifo2_write_req <= 1'b0;
    end
    else if(asfifo2_rdusedw <= 11'd256 && init_done_sync && fifo_write_hold && !HDMI_FRAMER1_DONE) begin
        fifo2_write_req <= 1'b1;
    end
    else begin
        fifo2_write_req <= 1'b0;
    end
end

assign HDMI_BUFFER1_REQ   = fifo1_write_req;
assign HDMI_BUFFER2_REQ   = fifo2_write_req;

always@(posedge SDRAM_CLK) begin
    asfifo1_we   <= SDRAM_P1_DV;
    asfifo1_di   <= SDRAM_P1_DATA;
    asfifo2_we   <= SDRAM_P2_DV;
    asfifo2_di   <= SDRAM_P2_DATA;
end

/*----------------------------------------------------------*/

asfifo_hdmi_driver asfifo1_hdmi_driver
(
    .rst                        (RESET | soft_reset ),
    .di                         (asfifo1_di         ),
    .clkr                       (HDMI_CLK           ),
    .re                         (asfifo1_re         ),
    .clkw                       (SDRAM_CLK          ),
    .we                         (asfifo1_we         ),
    .dout                       (asfifo1_dout       ),
    .empty_flag                 (asfifo1_empty_flag ),
    .aempty                     (),
    .full_flag                  (asfifo1_full_flag  ),
    .afull                      (),
    .valid                      (),
    .overflow                   (),
    .underflow                  (),
    .wr_success                 (),
    .rdusedw                    (asfifo1_rdusedw    ),
    .wrusedw                    (),
    .wr_rst_done                (),
    .rd_rst_done                ()
);

asfifo_hdmi_driver asfifo2_hdmi_driver
(
    .rst                        (RESET | soft_reset ),
    .di                         (asfifo2_di         ),
    .clkr                       (HDMI_CLK           ),
    .re                         (asfifo2_re         ),
    .clkw                       (SDRAM_CLK          ),
    .we                         (asfifo2_we         ),
    .dout                       (asfifo2_dout       ),
    .empty_flag                 (asfifo2_empty_flag ),
    .aempty                     (),
    .full_flag                  (asfifo2_full_flag  ),
    .afull                      (),
    .valid                      (),
    .overflow                   (),
    .underflow                  (),
    .wr_success                 (),
    .rdusedw                    (asfifo2_rdusedw    ),
    .wrusedw                    (),
    .wr_rst_done                (),
    .rd_rst_done                ()
);

assign asfifo1_re = pixel_req & init_done_sync && pixel_xpos < hdmi_valid_width && pixel_ypos <= hdmi_valid_height;
assign asfifo2_re = pixel_req & init_done_sync && pixel_xpos < hdmi_valid_width && pixel_ypos <= hdmi_valid_height;

always@(posedge HDMI_CLK) begin
    asfifo1_re_r <= asfifo1_re;
    asfifo2_re_r <= asfifo2_re;
end

/*----------------------------------------------------------*/

hdmi_driver #(
    .HDMI_MODE_SEL  ( HDMI_MODE_SEL     )
) hdmi_driver(
    .pixel_clk      (HDMI_CLK           ),
    .reset          (RESET              ),
		
    .o_hdmi_hs      (O_HDMI_HSYNC       ), 
    .o_hdmi_vs      (O_HDMI_VSYNC       ), 
    .o_hdmi_de      (O_HDMI_DE          ), 
    .o_hdmi_rgb     (                   ), 

    .pixel_req      (pixel_req          ),
    .pixel_xpos     (pixel_xpos         ),
    .pixel_ypos     (pixel_ypos         ),
    .pixel_data     (                   ),

    .head_flag      (head_flag          ),
    .new_flag       (BURST_NET_ROW_FLAG )
);

always@(posedge HDMI_CLK) begin
    pixel_xpos_r1 <= pixel_xpos;
    // 时序对齐：hdmi_driver 的 DE 在 pixel_req 之后打了两拍，
    // pixel_xpos 只跟 pixel_req 对齐。X 只延迟一拍时，有效区第一个点的
    // x 是 1。缩放器用 x==0 开写一行，写不进行缓存，读出的一直是上电数据，
    // 画面是不动的乱码。Y 已经和 DE 对齐，不再延迟。
    pixel_xpos_r2 <= pixel_xpos_r1;
    pixel_ypos_r1 <= pixel_ypos;
end

always@(posedge HDMI_CLK) begin
    pixel_data1 <= asfifo1_re_r ? asfifo1_dout : 24'd0;
    pixel_data2 <= asfifo2_re_r ? asfifo2_dout : 24'd0;
end

assign O_HDMI_XCNT = pixel_xpos_r2;
assign O_HDMI_YCNT = pixel_ypos_r1;
assign O_HDMI_RGB1 = pixel_data1;
assign O_HDMI_RGB2 = pixel_data2;


endmodule
