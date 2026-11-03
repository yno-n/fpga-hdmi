`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// ███╗   ███╗██╗   ██╗██╗  ██╗ █████╗ ███╗   ██╗
// ████╗ ████║██║   ██║██║  ██║██╔══██╗████╗  ██║
// ██╔████╔██║██║   ██║███████║███████║██╔██╗ ██║
// ██║╚██╔╝██║██║   ██║██╔══██║██╔══██║██║╚██╗██║
// ██║ ╚═╝ ██║╚██████╔╝██║  ██║██║  ██║██║ ╚████║
// ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
// Create Date: 2026/10/08 09:21:17
// Design Name: 
// Module Name: VPU_CUT_TO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 七种转场。rgb1 为当前图，rgb2 为下一张。
//              0 左滑，1 右滑，2 对角擦除，3 上下对开，4 棋盘，5 错行推移，6 十字展开。
//              cut_to_speed_set：0/1/2/3 对应 16/32/64/128 帧。模式和速度在场同步锁存。
//              cut_to_in_pchange 为异步脉冲，锁存到下一场同步再开始。
// Dependencies: dsp_mul_u8x9, dsp_mul_u9x10
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 边缘和黑场的积先寄存，混合系数再打一拍，像素积再打一拍。
//              PIX_LAT=3。几何量先打一拍再算系数，disable=1 时按该拍数透传 rgb1。
//              x 从 0 起且小于宽度、y 从 1 到高度为有效区，区外输出黑。
//              宽高在场同步锁存。左右滑跨度是宽加 64，右缘是宽减 1。
//              中心是宽的一半，垂直半宽是高减去高的一半。百叶窗跨度仍是 80。
//              跨度可以到 2047。dsp_mul_u9x10 只乘低 10 位，第 11 位用 prog 左移 10 位相加。
// 
//////////////////////////////////////////////////////////////////////////////////

module VPU_CUT_TO(
    input   wire                clk                         ,
    input   wire                reset                       ,

    input   wire    [12:0]      cut_to_valid_width          ,
    input   wire    [12:0]      cut_to_valid_height         ,

    input   wire                cut_to_disable              ,

    input   wire    [2:0]       cut_to_mode_set             ,
    input   wire    [1:0]       cut_to_speed_set            ,

    input   wire                cut_to_in_pchange           ,
    input   wire                cut_to_in_vsync             ,
    input   wire                cut_to_in_hsync             ,
    input   wire                cut_to_in_de                ,
    input   wire    [12:0]      cut_to_in_xcnt              ,
    input   wire    [12:0]      cut_to_in_ycnt              ,
    input   wire    [23:0]      cut_to_in_rgb1              ,
    input   wire    [23:0]      cut_to_in_rgb2              ,

    output  wire                cut_to_out_vsync            ,
    output  wire                cut_to_out_hsync            ,
    output  wire                cut_to_out_de               ,
    output  wire    [12:0]      cut_to_out_xcnt             ,
    output  wire    [12:0]      cut_to_out_ycnt             ,
    output  wire    [23:0]      cut_to_out_rgb              ,
    output  reg                 cut_to_out_done             
);

localparam                      BAND_SLIDE                  = 14'sd64;
localparam                      BAND_BLIND                  = 14'sd16;
localparam                      SPAN_BLIND                  = 11'd80;
localparam                      PIX_LAT                     = 3;

reg     [2:0]                   pchange_sync                ;
reg                             pchange_pending             ;
reg                             vsync_d                     ;
wire                            pchange_pos                 ;
wire                            vsync_pos                   ;

reg                             cut_busy                    ;
reg     [2:0]                   mode_latch                  ;
reg     [1:0]                   speed_latch                 ;
reg     [7:0]                   frame_latch                 ;
reg     [4:0]                   step_latch                  ;
reg     [8:0]                   prog                        ;
reg     [7:0]                   fade_i                      ;
reg     [12:0]                  width_l                     ;
reg     [12:0]                  height_l                    ;

reg     [2:0]                   cut_to_in_pchange_r3        ;
wire                            cut_to_in_pchange_pos       ;
wire                            cut_to_in_pchange_hold      ;
reg                             cut_to_in_pchange_end       ;

assign pchange_pos = pchange_sync[1] && !pchange_sync[2];
assign vsync_pos   = cut_to_in_vsync && !vsync_d;
assign cut_to_in_pchange_pos  = pchange_pos;
assign cut_to_in_pchange_hold = pchange_pending;

always@(posedge clk) begin
    if(reset) begin
        pchange_sync    <= 3'd0;
        vsync_d         <= 1'b0;
        pchange_pending <= 1'b0;
        cut_busy        <= 1'b0;
        mode_latch      <= 3'd0;
        speed_latch     <= 2'd1;
        frame_latch     <= 8'd32;
        step_latch      <= 5'd8;
        prog            <= 9'd0;
        fade_i          <= 8'd0;
        width_l         <= 13'd640;
        height_l        <= 13'd480;
        cut_to_out_done <= 1'b0;
        cut_to_in_pchange_end <= 1'b0;
        cut_to_in_pchange_r3  <= 3'd0;
    end
    else begin
        pchange_sync <= {pchange_sync[1:0], cut_to_in_pchange};
        cut_to_in_pchange_r3 <= {pchange_sync[1:0], cut_to_in_pchange};
        vsync_d      <= cut_to_in_vsync;
        cut_to_out_done <= 1'b0;
        cut_to_in_pchange_end <= 1'b0;

        if(vsync_pos) begin
            width_l  <= cut_to_valid_width;
            height_l <= cut_to_valid_height;
        end

        if(vsync_pos && cut_busy) begin
            if(pchange_pos) begin
                pchange_pending <= 1'b1;
            end
            if(prog + {4'd0, step_latch} >= 9'd256) begin
                prog <= 9'd256;
                cut_busy <= 1'b0;
                cut_to_out_done <= 1'b1;
                cut_to_in_pchange_end <= 1'b1;
            end
            else begin
                prog <= prog + {4'd0, step_latch};
            end
        end
        else if(vsync_pos && (pchange_pending || pchange_pos)) begin
            mode_latch  <= cut_to_mode_set;
            speed_latch <= cut_to_speed_set;
            case(cut_to_speed_set)
                2'd0: begin frame_latch <= 8'd16;  step_latch <= 5'd16; end
                2'd1: begin frame_latch <= 8'd32;  step_latch <= 5'd8;  end
                2'd2: begin frame_latch <= 8'd64;  step_latch <= 5'd4;  end
                default: begin frame_latch <= 8'd128; step_latch <= 5'd2; end
            endcase
            pchange_pending <= 1'b0;
            cut_busy <= 1'b1;
            fade_i   <= 8'd1;
            // 从旧图边缘开始。若第一场就把 prog 设成步长，左缘会先跳成新图。
            prog <= 9'd0;
        end
        else if(vsync_pos) begin
            // 结束后回到 0。停在 256 时整幅是 rgb2，下次一开始会从左侧弹回 rgb1。
            prog <= 9'd0;
        end
        else if(pchange_pos) begin
            pchange_pending <= 1'b1;
        end
    end
end

wire    [13:0]                  span_slide_w                ;
wire    [12:0]                  half_w                      ;
wire    [12:0]                  half_h                      ;
wire    [12:0]                  half_max                    ;
wire    [13:0]                  span_box_w                  ;
wire    [10:0]                  span_slide                  ;
wire    [10:0]                  span_box                    ;
wire    [10:0]                  span_sel                    ;
assign half_w = {1'b0, width_l[12:1]};
assign half_h = height_l - {1'b0, height_l[12:1]};
assign half_max = (half_w >= half_h) ? half_w : half_h;
assign span_slide_w = {1'b0, width_l} + 14'd64;
assign span_box_w = {1'b0, half_max} + 14'd64;
wire    [13:0]                  span_diag_w                 ;
wire    [13:0]                  span_barn_w                 ;
wire    [13:0]                  span_cross_w                ;
wire    [10:0]                  span_diag                   ;
wire    [10:0]                  span_barn                   ;
wire    [10:0]                  span_cross                  ;
assign span_diag_w  = {1'b0, width_l} + {1'b0, height_l} + 14'd64;
assign span_barn_w  = {1'b0, half_h} + 14'd64;
assign span_cross_w = {1'b0, half_max} + 14'd64;
// 错行最多把右缘再推迟 240 像素，跨度要盖住这一段和软边。
wire    [13:0]                  span_stag_w                 ;
wire    [10:0]                  span_stag                   ;
assign span_stag_w = {1'b0, width_l} + 14'd320;
assign span_slide = (span_slide_w > 14'd2047) ? 11'd2047 : span_slide_w[10:0];
assign span_box   = (span_box_w   > 14'd2047) ? 11'd2047 : span_box_w[10:0];
assign span_diag  = (span_diag_w  > 14'd2047) ? 11'd2047 : span_diag_w[10:0];
assign span_barn  = (span_barn_w  > 14'd2047) ? 11'd2047 : span_barn_w[10:0];
assign span_cross = (span_cross_w > 14'd2047) ? 11'd2047 : span_cross_w[10:0];
assign span_stag  = (span_stag_w  > 14'd2047) ? 11'd2047 : span_stag_w[10:0];
assign span_sel = (mode_latch == 3'd2) ? span_diag :
                  (mode_latch == 3'd3) ? span_barn :
                  (mode_latch == 3'd5) ? span_stag :
                  (mode_latch == 3'd6) ? span_cross : span_slide;
// 时序：75 MHz 从锁存高度做到跨度再进乘法器，建立时间 slack -0.712ns。
// 跨度一帧才变一次，先打一拍再乘。消隐远长于一拍，有效区用的是本帧跨度。
reg             [10:0]          span_q                      ;

wire    [18:0]                  edge_prod                   ;
wire    [12:0]                  edge_pix                    ;
reg     [12:0]                  edge_pix_q                  ;
reg     [8:0]                   black_level_q               ;
reg     [8:0]                   coef1_q                     ;
reg     [8:0]                   coef2_q                     ;
reg     [23:0]                  rgb1_d                      ;
reg     [23:0]                  rgb2_d                      ;
reg     [23:0]                  rgb1_d2                     ;
reg     [23:0]                  rgb2_d2                     ;
wire    [18:0]                  edge_hi                     ;
wire    [18:0]                  edge_sum                    ;
assign edge_hi = span_q[10] ? {prog, 10'd0} : 19'd0;
assign edge_sum = edge_prod + edge_hi;
assign edge_pix = {2'd0, edge_sum[18:8]};

dsp_mul_u9x10 U_MUL_EDGE(
    .CLK                        (clk                        ),
    .A                          (prog                       ),
    .B                          (span_q[9:0]                ),
    .P                          (edge_prod                  )
);

wire    [5:0]                   step_black                  ;
wire    [7:0]                   black_a                     ;
wire    [7:0]                   half_frame                  ;
wire    [16:0]                  black_full                  ;
wire    [13:0]                  black_prod                  ;
wire    [8:0]                   black_level                 ;

assign half_frame = {1'b0, frame_latch[7:1]};
assign step_black = {step_latch, 1'b0};
assign black_a = (fade_i <= half_frame) ? fade_i : (fade_i - half_frame);
assign black_prod = black_full[13:0];
assign black_level = (black_prod > 14'd256) ? 9'd256 : black_prod[8:0];

dsp_mul_u8x9 U_MUL_BLACK(
    .CLK                        (clk                        ),
    .A                          (black_a                    ),
    .B                          ({3'b0, step_black}         ),
    .P                          (black_full                 )
);

wire signed [13:0]              edge_s                      ;
wire signed [13:0]              x_s                         ;
wire signed [13:0]              y_s                         ;
wire signed [13:0]              dx_left                     ;
wire signed [13:0]              dx_right                    ;
wire signed [13:0]              dx_blind                    ;
wire signed [13:0]              dx_box                      ;
wire        [12:0]              abs_x                       ;
wire        [12:0]              abs_y                       ;
wire        [12:0]              cheb                        ;
wire        [7:0]               hash                        ;
reg signed  [13:0]              dx_left_q                   ;
reg signed  [13:0]              dx_right_q                  ;
reg signed  [13:0]              dx_blind_q                  ;
reg signed  [13:0]              dx_box_q                    ;
reg signed  [13:0]              dx_diag_q                   ;
reg signed  [13:0]              dx_top_q                    ;
reg signed  [13:0]              dx_bot_q                    ;
reg signed  [13:0]              dx_stag_q                   ;
reg signed  [13:0]              dx_ch_q                     ;
reg signed  [13:0]              dx_cv_q                     ;
reg         [12:0]              x_q                         ;
reg         [12:0]              y_q                         ;
reg                             tile_q                      ;
reg         [7:0]               hash_q                      ;
reg                             x_past_pic_q                ;
wire        [8:0]               k_pix                       ;
wire        [8:0]               coef1                       ;
wire        [8:0]               coef2                       ;

wire        [12:0]              box_cx                      ;
wire        [12:0]              box_cy                      ;
wire signed [13:0]              right_s                     ;
assign box_cx = {1'b0, width_l[12:1]};
assign box_cy = {1'b0, height_l[12:1]};
assign right_s = {1'b0, width_l} - 14'sd1;
assign edge_s = {1'b0, edge_pix_q};
assign x_s    = {1'b0, cut_to_in_xcnt};
assign y_s    = {1'b0, cut_to_in_ycnt};
assign dx_left  = edge_s - x_s;
assign dx_right = x_s - (right_s - edge_s);
assign dx_blind = edge_s - {8'd0, cut_to_in_xcnt[5:0]};
assign abs_x = (cut_to_in_xcnt >= box_cx) ? (cut_to_in_xcnt - box_cx) : (box_cx - cut_to_in_xcnt);
assign abs_y = (cut_to_in_ycnt >= box_cy) ? (cut_to_in_ycnt - box_cy) : (box_cy - cut_to_in_ycnt);
assign cheb  = (abs_x >= abs_y) ? abs_x : abs_y;
assign dx_box = edge_s - {1'b0, cheb};
wire signed [13:0]              dx_diag                     ;
wire signed [13:0]              dx_top                      ;
wire signed [13:0]              dx_bot                      ;
wire signed [13:0]              dx_stag                     ;
wire signed [13:0]              dx_ch                       ;
wire signed [13:0]              dx_cv                       ;
wire signed [13:0]              bot_edge                    ;
wire        [13:0]              stag_off                    ;
assign dx_diag = edge_s - (x_s + y_s);
assign dx_top  = edge_s - y_s;
assign bot_edge = {1'b0, height_l} - 14'sd1;
assign dx_bot  = y_s - (bot_edge - edge_s);
assign stag_off = {6'd0, cut_to_in_ycnt[7:4], 4'd0};
assign dx_stag = edge_s - x_s - $signed(stag_off);
assign dx_ch   = edge_s - {1'b0, abs_x};
assign dx_cv   = edge_s - {1'b0, abs_y};
assign hash = cut_to_in_xcnt[7:0] ^ cut_to_in_ycnt[7:0] ^ {cut_to_in_ycnt[3:0], cut_to_in_xcnt[3:0]};

function automatic [8:0] soft_k;
    input signed [13:0] dx;
    input signed [13:0] band;
    input integer       sh;
    begin
        if(dx <= 0) begin
            soft_k = 9'd0;
        end
        else if(dx >= band) begin
            soft_k = 9'd256;
        end
        else begin
            soft_k = dx[7:0] << sh;
        end
    end
endfunction

wire        [8:0]               prog_hi                     ;
wire        [8:0]               k_even                      ;
wire        [8:0]               k_odd                       ;
wire        [8:0]               k_chk                       ;
wire        [8:0]               k_arm_h                     ;
wire        [8:0]               k_arm_v                     ;
wire        [8:0]               k_cross                     ;
assign prog_hi = prog - 9'd128;
assign k_even  = (prog >= 9'd128) ? 9'd256 : {prog[7:0], 1'b0};
assign k_odd   = (prog <= 9'd128) ? 9'd0 : ((prog_hi >= 9'd128) ? 9'd256 : {prog_hi[7:0], 1'b0});
assign k_chk   = tile_q ? k_odd : k_even;
assign k_arm_h = soft_k(dx_ch_q, BAND_SLIDE, 2);
assign k_arm_v = soft_k(dx_cv_q, BAND_SLIDE, 2);
assign k_cross = (k_arm_h > k_arm_v) ? k_arm_h : k_arm_v;
assign k_pix =
    (prog >= 9'd256) ? 9'd256 :
    (mode_latch == 3'd0) ? soft_k(dx_left_q,  BAND_SLIDE, 2) :
    (mode_latch == 3'd1) ? soft_k(dx_right_q, BAND_SLIDE, 2) :
    (mode_latch == 3'd2) ? soft_k(dx_diag_q,  BAND_SLIDE, 2) :
    (mode_latch == 3'd3) ? ((y_q < {1'b0, height_l[12:1]}) ? soft_k(dx_top_q, BAND_SLIDE, 2)
                                                             : soft_k(dx_bot_q, BAND_SLIDE, 2)) :
    (mode_latch == 3'd4) ? k_chk :
    (mode_latch == 3'd5) ? soft_k(dx_stag_q, BAND_SLIDE, 2) :
    (mode_latch == 3'd6) ? k_cross :
                           soft_k(dx_left_q, BAND_SLIDE, 2);

assign coef1 = 9'd256 - k_pix;
assign coef2 = k_pix;

wire    [16:0]                  prod_r1_c                   ;
wire    [16:0]                  prod_g1_c                   ;
wire    [16:0]                  prod_b1_c                   ;
wire    [16:0]                  prod_r2_c                   ;
wire    [16:0]                  prod_g2_c                   ;
wire    [16:0]                  prod_b2_c                   ;
reg     [16:0]                  prod_r1                     ;
reg     [16:0]                  prod_g1                     ;
reg     [16:0]                  prod_b1                     ;
reg     [16:0]                  prod_r2                     ;
reg     [16:0]                  prod_g2                     ;
reg     [16:0]                  prod_b2                     ;

dsp_mul_u8x9 U_MUL_R1(
    .CLK                        (clk                        ),
    .A                          (rgb1_d2[23:16]             ),
    .B                          (coef1_q                    ),
    .P                          (prod_r1_c                  )
);

dsp_mul_u8x9 U_MUL_G1(
    .CLK                        (clk                        ),
    .A                          (rgb1_d2[15:8]              ),
    .B                          (coef1_q                    ),
    .P                          (prod_g1_c                  )
);

dsp_mul_u8x9 U_MUL_B1(
    .CLK                        (clk                        ),
    .A                          (rgb1_d2[7:0]               ),
    .B                          (coef1_q                    ),
    .P                          (prod_b1_c                  )
);

dsp_mul_u8x9 U_MUL_R2(
    .CLK                        (clk                        ),
    .A                          (rgb2_d2[23:16]             ),
    .B                          (coef2_q                    ),
    .P                          (prod_r2_c                  )
);

dsp_mul_u8x9 U_MUL_G2(
    .CLK                        (clk                        ),
    .A                          (rgb2_d2[15:8]              ),
    .B                          (coef2_q                    ),
    .P                          (prod_g2_c                  )
);

dsp_mul_u8x9 U_MUL_B2(
    .CLK                        (clk                        ),
    .A                          (rgb2_d2[7:0]               ),
    .B                          (coef2_q                    ),
    .P                          (prod_b2_c                  )
);

always@(posedge clk) begin
    if(reset) begin
        prod_r1 <= 17'd0;
        prod_g1 <= 17'd0;
        prod_b1 <= 17'd0;
        prod_r2 <= 17'd0;
        prod_g2 <= 17'd0;
        prod_b2        <= 17'd0;
        edge_pix_q     <= 13'd0;
        span_q         <= 11'd0;
        black_level_q  <= 9'd0;
        coef1_q        <= 9'd0;
        coef2_q        <= 9'd0;
        rgb1_d         <= 24'd0;
        rgb2_d         <= 24'd0;
        rgb1_d2        <= 24'd0;
        rgb2_d2        <= 24'd0;
        dx_left_q      <= 14'd0;
        dx_right_q     <= 14'd0;
        dx_blind_q     <= 14'd0;
        dx_box_q       <= 14'd0;
        dx_diag_q      <= 14'd0;
        dx_top_q       <= 14'd0;
        dx_bot_q       <= 14'd0;
        dx_stag_q      <= 14'd0;
        dx_ch_q        <= 14'd0;
        dx_cv_q        <= 14'd0;
        x_q            <= 13'd0;
        y_q            <= 13'd0;
        tile_q         <= 1'b0;
        hash_q         <= 8'd0;
        x_past_pic_q   <= 1'b0;
    end
    else begin
        span_q        <= span_sel;
        edge_pix_q    <= edge_pix;
        black_level_q <= black_level;
        coef1_q       <= coef1;
        coef2_q       <= coef2;
        rgb1_d        <= cut_to_in_rgb1;
        rgb2_d        <= cut_to_in_rgb2;
        rgb1_d2       <= rgb1_d;
        rgb2_d2       <= rgb2_d;
        dx_left_q     <= dx_left;
        dx_right_q    <= dx_right;
        dx_blind_q    <= dx_blind;
        dx_box_q      <= dx_box;
        dx_diag_q     <= dx_diag;
        dx_top_q      <= dx_top;
        dx_bot_q      <= dx_bot;
        dx_stag_q     <= dx_stag;
        dx_ch_q       <= dx_ch;
        dx_cv_q       <= dx_cv;
        x_q           <= cut_to_in_xcnt;
        y_q           <= cut_to_in_ycnt;
        tile_q        <= cut_to_in_xcnt[5] ^ cut_to_in_ycnt[5];
        hash_q        <= hash;
        x_past_pic_q  <= (cut_to_in_xcnt >= width_l);
        prod_r1 <= prod_r1_c;
        prod_g1 <= prod_g1_c;
        prod_b1 <= prod_b1_c;
        prod_r2 <= prod_r2_c;
        prod_g2 <= prod_g2_c;
        prod_b2 <= prod_b2_c;
    end
end

wire    [17:0]                  sum_r                       ;
wire    [17:0]                  sum_g                       ;
wire    [17:0]                  sum_b                       ;
assign sum_r = {1'b0, prod_r1} + {1'b0, prod_r2};
assign sum_g = {1'b0, prod_g1} + {1'b0, prod_g2};
assign sum_b = {1'b0, prod_b1} + {1'b0, prod_b2};

localparam                      PACK_W                      = 54;
wire    [PACK_W-1:0]            pack_in                     ;
reg     [PACK_W-1:0]            pack_dly [0:PIX_LAT-1]      ;
integer                         di                          ;
wire                            cut_dis_d                   ;
wire    [23:0]                  cut_rgb_d                   ;
wire    [12:0]                  cut_x_d                     ;
wire    [12:0]                  cut_y_d                     ;
wire                            cut_in_pic                  ;
wire    [23:0]                  cut_proc_rgb                ;

assign pack_in = {cut_to_disable, cut_to_in_rgb1,
                  cut_to_in_vsync, cut_to_in_hsync, cut_to_in_de,
                  cut_to_in_xcnt, cut_to_in_ycnt};

always@(posedge clk) begin
    if(reset) begin
        for(di = 0; di < PIX_LAT; di = di + 1) begin
            pack_dly[di] <= {PACK_W{1'b0}};
        end
    end
    else begin
        pack_dly[0] <= pack_in;
        for(di = 1; di < PIX_LAT; di = di + 1) begin
            pack_dly[di] <= pack_dly[di-1];
        end
    end
end

assign cut_dis_d    = pack_dly[PIX_LAT-1][53];
assign cut_rgb_d    = pack_dly[PIX_LAT-1][52:29];
assign cut_to_out_vsync = pack_dly[PIX_LAT-1][28];
assign cut_to_out_hsync = pack_dly[PIX_LAT-1][27];
assign cut_to_out_de    = pack_dly[PIX_LAT-1][26];
assign cut_to_out_xcnt  = pack_dly[PIX_LAT-1][25:13];
assign cut_to_out_ycnt  = pack_dly[PIX_LAT-1][12:0];
assign cut_x_d      = cut_to_out_xcnt;
assign cut_y_d      = cut_to_out_ycnt;
assign cut_in_pic   = (cut_x_d < cut_to_valid_width) &&
                      (cut_y_d >= 13'd1) &&
                      (cut_y_d <= cut_to_valid_height);
assign cut_proc_rgb = {sum_r[15:8], sum_g[15:8], sum_b[15:8]};
// 静止时直接用与坐标同拍的 rgb1。混合器多一拍或少一拍时，整幅会左移，
// 行尾把下一行的像素露在右边。
assign cut_to_out_rgb = cut_dis_d ? cut_rgb_d :
                        (cut_in_pic ? ((prog == 9'd0) ? cut_rgb_d : cut_proc_rgb) : 24'h000000);

endmodule
