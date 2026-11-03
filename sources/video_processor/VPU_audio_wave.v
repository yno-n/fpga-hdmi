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
// Create Date: 2026/10/20 17:40:00
// Design Name: 
// Module Name: VPU_audio_wave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 左声道 16 位叠到 HDMI。模式 0 是竖线波形，模式 1 是 64 根频率柱。
//              窗口宽 640、高 128，左上角是 audio_wave_sx/sy，场同步才锁存。
//              只画 640×480 内的部分。显示缓冲按场同步交换。
//              波形每隔 8 像素画一根 2 像素宽的竖线，从中线伸到采样点。
//              频谱是 256 点 Goertzel 的 64 个频率，隔一个原系数取一根，
//              柱宽 8 像素、间隔 2 像素。只用一个 dsp_mul_s16x16。
//              颜色 0 为绿色，1 为彩虹。
// 
// Dependencies: dsp_mul_s16x16, simple_dual_ram, audio_bin_coeff.mem
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 像素晚 3 拍。乘法器 IP 的输入输出寄存器是关的。
// 
//////////////////////////////////////////////////////////////////////////////////

module VPU_audio_wave #(
    parameter                   COEFF_FILE                  = "../sources/video_processor/audio_bin_coeff.mem"
)(
    input   wire                clk                         ,
    input   wire                reset                       ,

    input   wire                vpu_audio_disable           ,
    input   wire    [1:0]       vpu_audio_mode              ,
    input   wire    [1:0]       vpu_audio_color_mode        ,
    input   wire    [23:0]      vpu_audio_color_data        ,
    input   wire    [12:0]      audio_wave_sx               ,
    input   wire    [12:0]      audio_wave_sy               ,
    input   wire                vpu_audio_valid             ,
    input   wire    [15:0]      vpu_audio_data              ,

    input   wire                audio_wave_in_vsync         ,
    input   wire                audio_wave_in_hsync         ,
    input   wire                audio_wave_in_de            ,
    input   wire    [12:0]      audio_wave_in_xcnt          ,
    input   wire    [12:0]      audio_wave_in_ycnt          ,
    input   wire    [23:0]      audio_wave_in_rgb           ,

    output  reg                 audio_wave_out_vsync        ,
    output  reg                 audio_wave_out_hsync        ,
    output  reg                 audio_wave_out_de           ,
    output  reg     [12:0]      audio_wave_out_xcnt         ,
    output  reg     [12:0]      audio_wave_out_ycnt         ,
    output  reg     [23:0]      audio_wave_out_rgb          
);

localparam                      S_CLRD                      = 5'd0;
localparam                      S_CLRS                      = 5'd1;
localparam                      S_IDLE                      = 5'd2;
localparam                      S_W0                        = 5'd3;
localparam                      S_W1                        = 5'd4;
localparam                      S_W2                        = 5'd5;
localparam                      S_WW                        = 5'd6;
localparam                      S_G0                        = 5'd7;
localparam                      S_G1                        = 5'd8;
localparam                      S_G2                        = 5'd9;
localparam                      S_G3                        = 5'd10;
localparam                      S_A0                        = 5'd11;
localparam                      S_A1                        = 5'd12;
localparam                      S_A2                        = 5'd13;
localparam                      S_A3                        = 5'd14;
localparam                      S_A4                        = 5'd15;
localparam                      S_B0                        = 5'd16;
localparam                      S_B1                        = 5'd17;

localparam      signed [15:0]  WAVE_GAIN                   = 16'sd192;
localparam      [23:0]          GREEN                       = 24'h00C853;
localparam                      FIFO_DEPTH                  = 32;

reg             [4:0]           state                       ;
reg             [9:0]           clr_addr                    ;
reg             [8:0]           wptr                        ;
reg             [8:0]           wave_origin                 ;
reg                             disp_bank                   ;
reg                             cap_dirty                   ;
reg             [9:0]           wr_count                    ;
reg             [7:0]           k                           ;
reg             [7:0]           blk_cnt                     ;
reg     signed  [15:0]          samp                        ;
reg     signed  [15:0]          xs                          ;
reg     signed  [15:0]          v1                          ;
reg     signed  [15:0]          v2                          ;
reg     signed  [15:0]          mul_a                       ;
reg     signed  [15:0]          mul_b                       ;
reg     signed  [31:0]          prod_r                      ;
reg     signed  [31:0]          re_r                        ;
reg             [15:0]          peak_r                      ;
reg             [3:0]           shift_r                     ;
reg             [7:0]           wy                          ;

reg             [15:0]          fifo [0:FIFO_DEPTH-1]       ;
reg             [4:0]           fifo_w                      ;
reg             [4:0]           fifo_r                      ;
reg             [5:0]           fifo_cnt                    ;

reg                             we_d                        ;
reg             [9:0]           ad_d                        ;
reg             [7:0]           din_d                       ;
reg                             we_s                        ;
reg             [6:0]           ad_s                        ;
reg             [6:0]           ab_s                        ;
reg             [31:0]          din_s                       ;

reg                             vsync_d                     ;
reg                             dis_l                       ;
reg             [1:0]           mode_l                      ;
reg             [1:0]           cmode_l                     ;
reg             [23:0]          cdata_l                     ;
reg             [12:0]          sx_l                        ;
reg             [12:0]          sy_l                        ;

reg                             s1_vs, s1_hs, s1_de, s1_in  ;
reg             [1:0]           s1_mode                     ;
reg             [1:0]           s1_cmode                    ;
reg             [23:0]          s1_cdata                    ;
reg             [12:0]          s1_x, s1_y, s1_bot          ;
reg             [9:0]           s1_lx                       ;
reg             [23:0]          s1_rgb                      ;
reg             [7:0]           s1_bar                      ;
reg             [3:0]           s1_slot                     ;
reg                             s2_vs, s2_hs, s2_de, s2_in  ;
reg             [1:0]           s2_mode                     ;
reg             [1:0]           s2_cmode                    ;
reg             [23:0]          s2_cdata                    ;
reg             [12:0]          s2_x, s2_y, s2_bot          ;
reg             [9:0]           s2_lx                       ;
reg             [23:0]          s2_rgb                      ;
reg             [7:0]           s2_bar                      ;
reg             [3:0]           s2_slot                     ;
reg             [7:0]           s2_mem                      ;
// 时序：75 MHz 彩虹从横坐标乘 205 再混合，13 级加法，slack -0.137ns。
// 相位和同步先打一拍，混合只用这一拍。
reg             [7:0]           hue_ph_q                    ;
reg                             stroke_q                    ;
reg                             filled_q                    ;
reg                             bar_on_q                    ;
reg                             s3_vs, s3_hs, s3_de, s3_in  ;
reg             [1:0]           s3_mode                     ;
reg             [1:0]           s3_cmode                    ;
reg             [23:0]          s3_cdata                    ;
reg             [23:0]          s3_rgb                      ;
reg             [12:0]          s3_x, s3_y                  ;

reg     signed  [15:0]          trom [0:383]                ;

wire            [31:0]          prod_c                      ;
wire            [7:0]           dout_d                      ;
wire            [31:0]          dout_s                      ;
wire                            pop                         ;
wire                            push                        ;
wire                            vsync_rise                  ;
wire            [12:0]          bot                         ;
wire            [12:0]          x_rel                       ;
wire                            in_x                        ;
wire                            in_y                        ;
wire                            draw_mode                   ;
wire                            disp_lock                   ;
wire            [9:0]           x10                         ;
wire            [17:0]          x_ext                       ;
wire            [17:0]          x205                        ;
wire            [7:0]           bar_idx                     ;
wire            [9:0]           bar5                        ;
wire            [9:0]           slot_full                   ;
wire            [8:0]           wave_col                    ;
wire            [9:0]           wave_sum                    ;
wire            [8:0]           wave_idx                    ;
wire            [9:0]           disp_addr                   ;
wire            [9:0]           cap_wave_base               ;
wire            [9:0]           cap_bar_base                ;
wire    signed  [15:0]          coeff_k                     ;
wire    signed  [15:0]          cos_k                       ;
wire    signed  [15:0]          sin_k                       ;
wire    signed  [31:0]          y_sh                        ;
wire    signed  [31:0]          term                        ;
wire    signed  [31:0]          acc32                       ;
wire    signed  [15:0]          vnew                        ;
wire    signed  [31:0]          im_s                        ;
wire    signed  [31:0]          re_abs                      ;
wire    signed  [31:0]          im_abs                      ;
wire            [31:0]          mag_wide                    ;
wire            [15:0]          mag_sat                     ;
wire            [15:0]          peak_next                   ;
wire            [15:0]          mag_sh                      ;
wire            [7:0]           h_raw                       ;
wire            [12:0]          center                      ;
wire            [12:0]          sample_y                    ;
wire    signed  [13:0]          y_delta                     ;
wire                            stroke                      ;
wire            [12:0]          y_lo                        ;
wire            [12:0]          y_hi                        ;
wire                            filled                      ;
wire            [12:0]          bar_top                     ;
wire                            bar_on                      ;
wire            [9:0]           hue_x                       ;
wire            [17:0]          hue_ext                     ;
wire            [17:0]          hue_mul                     ;
wire            [7:0]           hue_ph                      ;
wire            [23:0]          fg_rgb                      ;
wire            [23:0]          rgb_mix                     ;
wire                            audio_busy                  ;
wire                            snap_ready                  ;

integer                         fi                          ;

initial $readmemh(COEFF_FILE, trom);

function [3:0] peak_shift;
    input [15:0] peak;
    integer bi2;
    reg [3:0] hb;
    begin
        hb = 4'd0;
        for(bi2 = 0; bi2 < 16; bi2 = bi2 + 1)
            if(peak[bi2])
                hb = bi2[3:0];
        if(hb > 4'd6)
            peak_shift = hb - 4'd6;
        else
            peak_shift = 4'd0;
    end
endfunction

assign bot        = sy_l + 13'd127;
assign x_rel      = audio_wave_in_xcnt - sx_l;
assign in_x       = (audio_wave_in_xcnt >= sx_l) && (x_rel < 13'd640) &&
                    (audio_wave_in_xcnt < 13'd640);
assign in_y       = (audio_wave_in_ycnt >= sy_l) &&
                    ((audio_wave_in_ycnt - sy_l) <= 13'd127) &&
                    (audio_wave_in_ycnt <= 13'd480);
assign draw_mode  = (mode_l == 2'd0) || (mode_l == 2'd1);
assign disp_lock  = draw_mode && !dis_l && audio_wave_in_de && in_x && in_y;
assign x10        = x_rel[9:0];
assign x_ext      = {8'd0, x10};
assign x205       = x10 * 10'd410;
assign bar_idx    = x205[17:12];
assign bar5       = {bar_idx, 3'b000} + {1'b0, bar_idx, 1'b0};
assign slot_full  = x10 - bar5;
assign wave_col   = {1'b0, x10[9:1]};
assign wave_sum   = {1'b0, wave_origin} + {1'b0, wave_col};
assign wave_idx   = (wave_sum >= 10'd320) ? (wave_sum - 10'd320) : wave_sum[8:0];
assign disp_addr  = (mode_l == 2'd0)
                    ? ((disp_bank ? 10'd320 : 10'd0) + {1'b0, wave_idx})
                    : ((disp_bank ? 10'd768 : 10'd640) + {2'd0, bar_idx});
assign cap_wave_base = disp_bank ? 10'd0   : 10'd320;
assign cap_bar_base  = disp_bank ? 10'd640 : 10'd768;
assign coeff_k    = trom[{k[5:0], 1'b0}];
assign cos_k      = trom[9'd128 + {k[5:0], 1'b0}];
assign sin_k      = trom[9'd256 + {k[5:0], 1'b0}];
assign vsync_rise = audio_wave_in_vsync && !vsync_d;
assign pop        = (state == S_IDLE) && (fifo_cnt != 6'd0);
assign push       = vpu_audio_valid && ((fifo_cnt < FIFO_DEPTH) || pop);
assign audio_busy = (state != S_IDLE) || (fifo_cnt != 6'd0);
assign snap_ready = (state == S_IDLE) && (fifo_cnt == 6'd0);

assign y_sh       = prod_r >>> 15;
assign term       = prod_r >>> 14;
assign acc32      = {{16{xs[15]}}, xs} + term - {{16{v2[15]}}, v2};
assign vnew       = (acc32 > 32'sd32767)  ? 16'sd32767 :
                    (acc32 < -32'sd32768) ? -16'sd32768 : acc32[15:0];
assign im_s       = prod_r >>> 14;
assign re_abs     = re_r[31] ? -re_r : re_r;
assign im_abs     = im_s[31] ? -im_s : im_s;
assign mag_wide   = re_abs + im_abs;
assign mag_sat    = (mag_wide > 32'd65535) ? 16'hFFFF : mag_wide[15:0];
assign peak_next  = (mag_sat > peak_r) ? mag_sat : peak_r;
assign mag_sh     = dout_s[15:0] >> shift_r;
assign h_raw      = (mag_sh > 16'd127) ? 8'd127 : mag_sh[7:0];

dsp_mul_s16x16 U_MUL(
    .CLK                        (clk                        ),
    .A                          (mul_a                      ),
    .B                          (mul_b                      ),
    .P                          (prod_c                     )
);

simple_dual_ram #(
    .RAM_WIDTH                  (8                          ),
    .RAM_DEPTH                  (1024                       ),
    .PERFORMENCE                ("LOW"                      )
)U_DISP(
    .clka                       (clk                        ),
    .wea                        (we_d                       ),
    .dina                       (din_d                      ),
    .addra                      (ad_d                       ),
    .addrb                      (disp_lock ? disp_addr : 10'd0),
    .doutb                      (dout_d                     )
);

simple_dual_ram #(
    .RAM_WIDTH                  (32                         ),
    .RAM_DEPTH                  (128                        ),
    .PERFORMENCE                ("LOW"                      )
)U_STATE(
    .clka                       (clk                        ),
    .wea                        (we_s                       ),
    .dina                       (din_s                      ),
    .addra                      (ad_s                       ),
    .addrb                      (ab_s                       ),
    .doutb                      (dout_s                     )
);

always@(posedge clk) begin
    if(reset) begin
        vsync_d <= 1'b0;
        dis_l   <= 1'b0;
        mode_l  <= 2'd0;
        cmode_l <= 2'd0;
        cdata_l <= GREEN;
        sx_l    <= 13'd0;
        sy_l    <= 13'd352;
    end
    else begin
        vsync_d <= audio_wave_in_vsync;
        if(vsync_rise) begin
            dis_l   <= vpu_audio_disable;
            mode_l  <= vpu_audio_mode;
            cmode_l <= vpu_audio_color_mode;
            cdata_l <= vpu_audio_color_data;
            sx_l    <= audio_wave_sx;
            sy_l    <= audio_wave_sy;
        end
    end
end

always@(posedge clk) begin
    if(reset) begin
        state       <= S_CLRD;
        clr_addr    <= 10'd0;
        wptr        <= 9'd0;
        wave_origin <= 9'd0;
        disp_bank   <= 1'b0;
        cap_dirty   <= 1'b0;
        wr_count    <= 10'd0;
        k           <= 8'd0;
        blk_cnt     <= 8'd0;
        samp        <= 16'sd0;
        xs          <= 16'sd0;
        v1          <= 16'sd0;
        v2          <= 16'sd0;
        mul_a       <= 16'sd0;
        mul_b       <= 16'sd0;
        prod_r      <= 32'sd0;
        re_r        <= 32'sd0;
        peak_r      <= 16'd0;
        shift_r     <= 4'd0;
        wy          <= 8'd64;
        we_d        <= 1'b0;
        ad_d        <= 10'd0;
        din_d       <= 8'd0;
        we_s        <= 1'b0;
        ad_s        <= 7'd0;
        ab_s        <= 7'd0;
        din_s       <= 32'd0;
        fifo_w      <= 5'd0;
        fifo_r      <= 5'd0;
        fifo_cnt    <= 6'd0;
        for(fi = 0; fi < FIFO_DEPTH; fi = fi + 1)
            fifo[fi] <= 16'd0;
    end
    else begin
        we_d <= 1'b0;
        we_s <= 1'b0;
        case(state)
            S_CLRD: begin
                we_d  <= 1'b1;
                ad_d  <= clr_addr;
                din_d <= (clr_addr < 10'd640) ? 8'd64 : 8'd0;
                if(clr_addr == 10'd1023) begin
                    clr_addr <= 10'd0;
                    state    <= S_CLRS;
                end
                else
                    clr_addr <= clr_addr + 10'd1;
            end
            S_CLRS: begin
                we_s  <= 1'b1;
                ad_s  <= clr_addr[6:0];
                din_s <= 32'd0;
                if(clr_addr == 10'd127)
                    state <= S_IDLE;
                else
                    clr_addr <= clr_addr + 10'd1;
            end
            S_IDLE: begin
            end
            S_W0: begin
                mul_a <= samp;
                mul_b <= WAVE_GAIN;
                xs    <= samp >>> 8;
                state <= S_W1;
            end
            S_W1: begin
                prod_r <= prod_c;
                state  <= S_W2;
            end
            S_W2: begin
                if(y_sh > 32'sd63)
                    wy <= 8'd127;
                else if(y_sh < -32'sd63)
                    wy <= 8'd1;
                else
                    wy <= y_sh[7:0] + 8'd64;
                state <= S_WW;
            end
            S_WW: begin
                we_d      <= 1'b1;
                ad_d      <= cap_wave_base + {1'b0, wptr};
                din_d     <= wy;
                wptr      <= (wptr == 9'd319) ? 9'd0 : (wptr + 9'd1);
                if(wr_count < 10'd320)
                    wr_count <= wr_count + 10'd1;
                cap_dirty <= 1'b1;
                k         <= 8'd0;
                ab_s      <= 7'd0;
                state     <= S_G0;
            end
            S_G0: begin
                ab_s  <= 7'd0;
                state <= S_G1;
            end
            S_G1: begin
                v1    <= dout_s[15:0];
                v2    <= dout_s[31:16];
                mul_a <= dout_s[15:0];
                mul_b <= coeff_k;
                state <= S_G2;
            end
            S_G2: begin
                prod_r <= prod_c;
                if(k != 8'd63)
                    ab_s <= k[6:0] + 7'd1;
                state <= S_G3;
            end
            S_G3: begin
                we_s  <= 1'b1;
                ad_s  <= k[6:0];
                din_s <= {v1, vnew};
                if(k == 8'd63) begin
                    k <= 8'd0;
                    if(blk_cnt == 8'd255) begin
                        ab_s   <= 7'd0;
                        peak_r <= 16'd0;
                        state  <= S_A0;
                    end
                    else begin
                        blk_cnt <= blk_cnt + 8'd1;
                        state   <= S_IDLE;
                    end
                end
                else begin
                    k     <= k + 8'd1;
                    state <= S_G1;
                end
            end
            S_A0: begin
                ab_s  <= 7'd0;
                state <= S_A1;
            end
            S_A1: begin
                v1    <= dout_s[15:0];
                v2    <= dout_s[31:16];
                mul_a <= dout_s[31:16];
                mul_b <= cos_k;
                state <= S_A2;
            end
            S_A2: begin
                prod_r <= prod_c;
                mul_a  <= v2;
                mul_b  <= sin_k;
                state  <= S_A3;
            end
            S_A3: begin
                re_r   <= {{16{v1[15]}}, v1} - term;
                prod_r <= prod_c;
                if(k != 8'd63)
                    ab_s <= k[6:0] + 7'd1;
                state  <= S_A4;
            end
            S_A4: begin
                we_s   <= 1'b1;
                ad_s   <= k[6:0];
                din_s  <= {16'd0, mag_sat};
                peak_r <= peak_next;
                if(k == 8'd63) begin
                    shift_r <= peak_shift(peak_next);
                    k       <= 8'd0;
                    ab_s    <= 7'd0;
                    state   <= S_B0;
                end
                else begin
                    k     <= k + 8'd1;
                    state <= S_A1;
                end
            end
            S_B0: begin
                ab_s  <= 7'd1;
                k     <= 8'd0;
                state <= S_B1;
            end
            S_B1: begin
                we_d  <= 1'b1;
                ad_d  <= cap_bar_base + {2'd0, k};
                din_d <= h_raw;
                we_s  <= 1'b1;
                ad_s  <= k[6:0];
                din_s <= 32'd0;
                if(k == 8'd63) begin
                    blk_cnt <= 8'd0;
                    state   <= S_IDLE;
                end
                else begin
                    k    <= k + 8'd1;
                    if(k < 8'd62)
                        ab_s <= k[6:0] + 7'd2;
                end
            end
            default: begin
                state <= S_IDLE;
            end
        endcase

        if(vsync_rise && cap_dirty) begin
            disp_bank   <= ~disp_bank;
            wave_origin <= (wr_count >= 10'd320) ? wptr : 9'd0;
            wptr        <= 9'd0;
            wr_count    <= 10'd0;
            cap_dirty   <= 1'b0;
        end

        if(push && !pop)
            fifo_cnt <= fifo_cnt + 6'd1;
        else if(!push && pop)
            fifo_cnt <= fifo_cnt - 6'd1;
        if(push) begin
            fifo[fifo_w] <= vpu_audio_data;
            fifo_w       <= fifo_w + 5'd1;
        end
        if(pop) begin
            samp   <= fifo[fifo_r];
            fifo_r <= fifo_r + 5'd1;
            state  <= S_W0;
        end
    end
end

always@(posedge clk) begin
    if(reset) begin
        s1_vs <= 1'b0; s1_hs <= 1'b0; s1_de <= 1'b0; s1_in <= 1'b0;
        s1_mode <= 2'd0; s1_cmode <= 2'd0; s1_cdata <= GREEN;
        s1_x <= 13'd0; s1_y <= 13'd0; s1_bot <= 13'd0; s1_lx <= 10'd0;
        s1_rgb <= 24'd0; s1_bar <= 8'd0; s1_slot <= 3'd0;
        s2_vs <= 1'b0; s2_hs <= 1'b0; s2_de <= 1'b0; s2_in <= 1'b0;
        s2_mode <= 2'd0; s2_cmode <= 2'd0; s2_cdata <= GREEN;
        s2_x <= 13'd0; s2_y <= 13'd0; s2_bot <= 13'd0; s2_lx <= 10'd0;
        s2_rgb <= 24'd0; s2_bar <= 8'd0; s2_slot <= 3'd0; s2_mem <= 8'd64;
    end
    else begin
        s1_vs   <= audio_wave_in_vsync;
        s1_hs   <= audio_wave_in_hsync;
        s1_de   <= audio_wave_in_de;
        s1_in   <= disp_lock;
        s1_mode  <= mode_l;
        s1_cmode <= cmode_l;
        s1_cdata <= cdata_l;
        s1_x    <= audio_wave_in_xcnt;
        s1_y    <= audio_wave_in_ycnt;
        s1_lx   <= x10;
        s1_bot  <= bot;
        s1_rgb  <= audio_wave_in_rgb;
        s1_bar  <= bar_idx;
        s1_slot <= slot_full[3:0];
        s2_vs   <= s1_vs;
        s2_hs   <= s1_hs;
        s2_de   <= s1_de;
        s2_in   <= s1_in;
        s2_mode  <= s1_mode;
        s2_cmode <= s1_cmode;
        s2_cdata <= s1_cdata;
        s2_x    <= s1_x;
        s2_y    <= s1_y;
        s2_lx   <= s1_lx;
        s2_bot  <= s1_bot;
        s2_rgb  <= s1_rgb;
        s2_bar  <= s1_bar;
        s2_slot <= s1_slot;
        s2_mem  <= dout_d;
    end
end

assign center   = s2_bot - 13'd64;
assign sample_y = s2_bot - {5'd0, s2_mem};
assign y_delta  = $signed({1'b0, s2_y}) - $signed({1'b0, sample_y});
assign stroke   = (y_delta <= 14'sd1) && (y_delta >= -14'sd1);
assign y_lo     = (sample_y < center) ? sample_y : center;
assign y_hi     = (sample_y > center) ? sample_y : center;
assign filled   = (s2_lx[2:0] <= 3'd1) && (s2_y >= y_lo) && (s2_y <= y_hi);
assign bar_top  = s2_bot - {5'd0, s2_mem} + 13'd1;
assign bar_on   = (s2_mem != 8'd0) && (s2_slot < 4'd8) &&
                  (s2_y >= bar_top) && (s2_y <= s2_bot);

function [7:0] hue_tri;
    input [7:0] phase;
    reg   [7:0] fold;
    begin
        if(phase < 8'd128)
            hue_tri = {phase[6:0], 1'b0};
        else begin
            fold    = 8'd255 - phase;
            hue_tri = {fold[6:0], 1'b0};
        end
    end
endfunction

function [7:0] mix25;
    input [7:0] bg;
    input [7:0] fg;
    reg   [9:0] sum;
    begin
        sum   = {2'd0, bg} + {2'd0, bg} + {2'd0, bg} + {2'd0, fg};
        mix25 = sum[9:2];
    end
endfunction

function [7:0] mix50;
    input [7:0] bg;
    input [7:0] fg;
    reg   [8:0] sum;
    begin
        sum   = {1'b0, bg} + {1'b0, fg};
        mix50 = sum[8:1];
    end
endfunction

assign hue_x   = s2_lx;
assign hue_ext = {8'd0, hue_x};
assign hue_mul = (hue_ext << 7) + (hue_ext << 6) + (hue_ext << 3) + (hue_ext << 2) + hue_ext;
assign hue_ph  = hue_mul[16:9];
assign fg_rgb  = (s3_cmode == 2'd1) ? {hue_tri(hue_ph_q),
                                       hue_tri(hue_ph_q + 8'd85),
                                       hue_tri(hue_ph_q + 8'd170)} :
                                      GREEN;

assign rgb_mix =
    (!s3_in) ? s3_rgb :
    (s3_mode == 2'd0) ? (filled_q ? fg_rgb : s3_rgb) :
    (s3_mode == 2'd1 && bar_on_q) ?
        {mix50(s3_rgb[23:16], fg_rgb[23:16]),
         mix50(s3_rgb[15:8],  fg_rgb[15:8]),
         mix50(s3_rgb[7:0],   fg_rgb[7:0])} :
    s3_rgb;

always@(posedge clk) begin
    if(reset) begin
        audio_wave_out_vsync <= 1'b0;
        audio_wave_out_hsync <= 1'b0;
        audio_wave_out_de    <= 1'b0;
        audio_wave_out_xcnt  <= 13'd0;
        audio_wave_out_ycnt  <= 13'd0;
        audio_wave_out_rgb   <= 24'd0;
        hue_ph_q  <= 8'd0;
        stroke_q  <= 1'b0;
        filled_q  <= 1'b0;
        bar_on_q  <= 1'b0;
        s3_vs <= 1'b0; s3_hs <= 1'b0; s3_de <= 1'b0; s3_in <= 1'b0;
        s3_mode <= 2'd0; s3_cmode <= 2'd0;
        s3_cdata <= 24'd0; s3_rgb <= 24'd0;
        s3_x <= 13'd0; s3_y <= 13'd0;
    end
    else begin
        hue_ph_q <= hue_ph;
        stroke_q <= stroke;
        filled_q <= filled;
        bar_on_q <= bar_on;
        s3_vs    <= s2_vs;
        s3_hs    <= s2_hs;
        s3_de    <= s2_de;
        s3_in    <= s2_in;
        s3_mode  <= s2_mode;
        s3_cmode <= s2_cmode;
        s3_cdata <= s2_cdata;
        s3_rgb   <= s2_rgb;
        s3_x     <= s2_x;
        s3_y     <= s2_y;
        audio_wave_out_vsync <= s3_vs;
        audio_wave_out_hsync <= s3_hs;
        audio_wave_out_de    <= s3_de;
        audio_wave_out_xcnt  <= s3_x;
        audio_wave_out_ycnt  <= s3_y;
        audio_wave_out_rgb   <= rgb_mix;
    end
end

endmodule
