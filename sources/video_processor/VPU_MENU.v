`timescale 1ns / 1ps

// 右侧 OSD 菜单。上下选行，中间键进入或退出调节，左右只在调节时改值。
// 字模 16x16。面板在画面上混合，同步和坐标晚一拍。
module VPU_MENU (
    input   wire                clk                         ,
    input   wire                reset                       ,

    input   wire                menu_power                  ,
    input   wire                menu_up                     ,
    input   wire                menu_down                   ,
    input   wire                menu_left                   ,
    input   wire                menu_right                  ,
    input   wire                menu_center                 ,

    output  wire    [2:0]       cut_to_mode_set             ,
    output  wire    [1:0]       cut_to_speed_set            ,
    output  wire                cut_to_disable              ,

    output  wire                dis_eff_disable             ,
    output  wire    [7:0]       lumi_set_data               ,
    output  wire    [7:0]       contrast_set_data           ,
    output  wire    [7:0]       temp_set_data               ,
    output  wire    [7:0]       tint_set_data               ,

    output  wire                osd_disable                 ,
    output  wire    [12:0]      osd_logo_sx                 ,
    output  wire    [12:0]      osd_logo_sy                 ,
    output  wire    [12:0]      osd_txt_sx                  ,
    output  wire    [12:0]      osd_txt_sy                  ,
    output  wire    [12:0]      osd_txt_x_area              ,
    output  wire    [1:0]       osd_txt_speed               ,
    output  wire    [1:0]       osd_color_mode              ,

    output  wire                style_disable               ,
    output  wire    [2:0]       style_mode                  ,
    output  wire    [7:0]       style_bin_th                ,
    output  wire    [7:0]       style_gamma                 ,

    output  wire                vpu_audio_disable           ,
    output  wire    [1:0]       vpu_audio_mode              ,
    output  wire    [1:0]       vpu_audio_color_mode        ,
    output  wire    [12:0]      vpu_audio_sx                ,
    output  wire    [12:0]      vpu_audio_sy                ,

    input   wire                menu_in_vsync               ,
    input   wire                menu_in_hsync               ,
    input   wire                menu_in_de                  ,
    input   wire    [12:0]      menu_in_xcnt                ,
    input   wire    [12:0]      menu_in_ycnt                ,
    input   wire    [23:0]      menu_in_rgb                 ,

    output  reg                 menu_out_vsync              ,
    output  reg                 menu_out_hsync              ,
    output  reg                 menu_out_de                 ,
    output  reg     [12:0]      menu_out_xcnt               ,
    output  reg     [12:0]      menu_out_ycnt               ,
    output  reg     [23:0]      menu_out_rgb
);

`include "menu_font.vh"

localparam      [12:0]          PANEL_X                     = 13'd392;
localparam      [12:0]          PANEL_Y                     = 13'd64;
localparam      [12:0]          PANEL_W                     = 13'd240;
localparam      [12:0]          ROW_H                       = 13'd40;
localparam      [23:0]          COL_NAVY                    = 24'h1C2D4E;
localparam      [23:0]          COL_RED                     = 24'hED1C24;

reg                             menu_on                     ;
reg                             edit                        ;
reg             [3:0]           sel                         ;
reg             [2:0]           cut_mode                    ;
reg             [1:0]           spd_i                       ;
reg             [7:0]           lumi                        ;
reg             [7:0]           contrast                    ;
reg             [7:0]           temper                      ;
reg             [7:0]           tint                        ;
reg             [2:0]           style_i                     ;
reg             [7:0]           strength                    ;
reg             [1:0]           audio_sel                   ;
reg                             audio_color                 ;
reg                             txt_color                   ;
reg             [1:0]           txt_spd                     ;
reg             [12:0]          txt_x                       ;
reg             [12:0]          txt_y                       ;
reg             [4:0]           blink                       ;
reg                             vsync_d                     ;

wire            [3:0]           base                        ;
wire                            in_panel                    ;
wire            [12:0]          dx                          ;
wire            [12:0]          dy                          ;
wire            [2:0]           row                         ;
wire            [3:0]           item                        ;
wire            [12:0]          y_in_row                    ;
wire                            in_glyph_y                  ;
wire                            in_label                    ;
wire                            in_value                    ;
wire            [1:0]           glyph_col                   ;
wire            [3:0]           glyph_x                     ;
wire            [3:0]           glyph_y                     ;
wire            [6:0]           gid                         ;
wire            [15:0]          grow                        ;
wire                            bit_on                      ;
wire                            sel_row                     ;
wire                            hide_value                  ;
wire            [8:0]           item_val                    ;
wire            [23:0]          panel_rgb                   ;
wire            [23:0]          pix_rgb                     ;

assign cut_to_mode_set      = cut_mode;
assign cut_to_speed_set     = (spd_i == 2'd0) ? 2'd2 : (spd_i == 2'd1) ? 2'd1 : 2'd0;
assign cut_to_disable       = 1'b0;
assign dis_eff_disable      = 1'b0;
assign lumi_set_data        = lumi;
assign contrast_set_data    = contrast;
assign temp_set_data        = temper;
assign tint_set_data        = tint;
assign osd_disable          = 1'b0;
assign osd_logo_sx          = 13'd8;
assign osd_logo_sy          = 13'd8;
assign osd_txt_sx           = txt_x;
assign osd_txt_sy           = txt_y;
assign osd_txt_x_area       = 13'd480;
assign osd_txt_speed        = txt_spd;
assign osd_color_mode       = {1'b0, txt_color};
assign style_disable        = 1'b0;
assign style_mode           = style_i;
assign style_bin_th         = strength;
assign style_gamma          = strength;
assign vpu_audio_disable    = (audio_sel == 2'd0);
assign vpu_audio_mode       = (audio_sel == 2'd2) ? 2'd1 : 2'd0;
assign vpu_audio_color_mode = {1'b0, audio_color};
assign vpu_audio_sx         = 13'd0;
assign vpu_audio_sy         = 13'd352;

assign base = (sel <= 4'd3) ? 4'd0 : (sel >= 4'd10) ? 4'd6 : (sel - 4'd3);

function [7:0] mix50;
    input [7:0] bg;
    input [7:0] fg;
    reg   [8:0] sum;
    begin
        sum   = {1'b0, bg} + {1'b0, fg};
        mix50 = sum[8:1];
    end
endfunction

function [23:0] mix24;
    input [23:0] bg;
    input [23:0] fg;
    begin
        mix24 = {mix50(bg[23:16], fg[23:16]),
                 mix50(bg[15:8],  fg[15:8]),
                 mix50(bg[7:0],   fg[7:0])};
    end
endfunction

function [2:0] row_of;
    input [12:0] rel;
    begin
        if(rel < 13'd40)       row_of = 3'd0;
        else if(rel < 13'd80)  row_of = 3'd1;
        else if(rel < 13'd120) row_of = 3'd2;
        else if(rel < 13'd160) row_of = 3'd3;
        else if(rel < 13'd200) row_of = 3'd4;
        else if(rel < 13'd240) row_of = 3'd5;
        else if(rel < 13'd280) row_of = 3'd6;
        else                   row_of = 3'd7;
    end
endfunction

function [8:0] val_of;
    input [3:0] which;
    begin
        case(which)
            4'd0:  val_of = {6'd0, cut_mode};
            4'd1:  val_of = {7'd0, spd_i};
            4'd2:  val_of = {1'b0, lumi};
            4'd3:  val_of = {1'b0, contrast};
            4'd4:  val_of = {1'b0, temper};
            4'd5:  val_of = {1'b0, tint};
            4'd6:  val_of = {6'd0, style_i};
            4'd7:  val_of = {1'b0, strength};
            4'd8:  val_of = {7'd0, audio_sel};
            4'd9:  val_of = {8'd0, audio_color};
            4'd10: val_of = {8'd0, txt_color};
            4'd11: val_of = {7'd0, txt_spd};
            4'd12: val_of = {1'b0, txt_x[7:0]};
            default: val_of = txt_y[8:0];
        endcase
    end
endfunction

assign in_panel = menu_on && menu_in_de &&
                  (menu_in_xcnt >= PANEL_X) && (menu_in_xcnt < PANEL_X + PANEL_W) &&
                  (menu_in_ycnt >= PANEL_Y) && (menu_in_ycnt < PANEL_Y + ROW_H * 8);
assign dx = menu_in_xcnt - PANEL_X;
assign dy = menu_in_ycnt - PANEL_Y;
assign row = row_of(dy);
assign item = base + {1'b0, row};
assign y_in_row = dy - (row * ROW_H);
assign in_glyph_y = (y_in_row >= 13'd12) && (y_in_row < 13'd28);
assign in_label = in_glyph_y && (dx >= 13'd8) && (dx < 13'd72);
assign in_value = in_glyph_y && (dx >= 13'd104) && (dx < 13'd168);
assign glyph_col = in_value ? (dx - 13'd104) >> 4 : (dx - 13'd8) >> 4;
assign glyph_x = in_value ? (dx - 13'd104) : (dx - 13'd8);
assign glyph_y = y_in_row - 13'd12;
assign item_val = val_of(item);
assign gid = in_value ? menu_value_gid(item, item_val, glyph_col)
                      : menu_label_gid(item, glyph_col);
assign grow = menu_glyph_row(gid, glyph_y);
assign sel_row = (item == sel);
assign hide_value = edit && sel_row && blink[4] && in_value;
assign bit_on = (in_label || in_value) && !hide_value && grow[4'd15 - glyph_x];
assign panel_rgb = sel_row ? mix24(menu_in_rgb, COL_RED) : mix24(menu_in_rgb, COL_NAVY);
assign pix_rgb = !in_panel ? menu_in_rgb : (bit_on ? 24'hFFFFFF : panel_rgb);

always @(posedge clk) begin
    if(reset) begin
        menu_on     <= 1'b0;
        edit        <= 1'b0;
        sel         <= 4'd0;
        cut_mode    <= 3'd0;
        spd_i       <= 2'd1;
        lumi        <= 8'd128;
        contrast    <= 8'd128;
        temper      <= 8'd128;
        tint        <= 8'd128;
        style_i     <= 3'd0;
        strength    <= 8'd128;
        audio_sel   <= 2'd1;
        audio_color <= 1'b0;
        txt_color   <= 1'b0;
        txt_spd     <= 2'd1;
        txt_x       <= 13'd80;
        txt_y       <= 13'd8;
        blink       <= 5'd0;
        vsync_d     <= 1'b0;
    end
    else begin
        vsync_d <= menu_in_vsync;
        if(menu_in_vsync && !vsync_d)
            blink <= blink + 5'd1;
        if(menu_power) begin
            menu_on <= ~menu_on;
            edit    <= 1'b0;
        end
        else if(menu_on && menu_up) begin
            edit <= 1'b0;
            sel  <= (sel == 4'd0) ? 4'd13 : sel - 4'd1;
        end
        else if(menu_on && menu_down) begin
            edit <= 1'b0;
            sel  <= (sel == 4'd13) ? 4'd0 : sel + 4'd1;
        end
        else if(menu_on && menu_center) begin
            edit <= ~edit;
        end
        else if(menu_on && edit && menu_left) begin
            case(sel)
                4'd0:  cut_mode <= (cut_mode == 3'd0) ? 3'd6 : cut_mode - 3'd1;
                4'd1:  spd_i <= (spd_i == 2'd0) ? 2'd2 : spd_i - 2'd1;
                4'd2:  if(lumi >= 8'd8) lumi <= lumi - 8'd8;
                4'd3:  if(contrast >= 8'd8) contrast <= contrast - 8'd8;
                4'd4:  if(temper >= 8'd8) temper <= temper - 8'd8;
                4'd5:  if(tint >= 8'd8) tint <= tint - 8'd8;
                4'd6:  style_i <= (style_i == 3'd0) ? 3'd4 : style_i - 3'd1;
                4'd7:  if(strength >= 8'd16) strength <= strength - 8'd16;
                4'd8:  audio_sel <= (audio_sel == 2'd0) ? 2'd2 : audio_sel - 2'd1;
                4'd9:  audio_color <= ~audio_color;
                4'd10: txt_color <= ~txt_color;
                4'd11: txt_spd <= (txt_spd == 2'd0) ? 2'd2 : txt_spd - 2'd1;
                4'd12: txt_x <= (txt_x <= 13'd16) ? 13'd0 : txt_x - 13'd16;
                default: txt_y <= (txt_y <= 13'd16) ? 13'd0 : txt_y - 13'd16;
            endcase
        end
        else if(menu_on && edit && menu_right) begin
            case(sel)
                4'd0:  cut_mode <= (cut_mode == 3'd6) ? 3'd0 : cut_mode + 3'd1;
                4'd1:  spd_i <= (spd_i == 2'd2) ? 2'd0 : spd_i + 2'd1;
                4'd2:  if(lumi <= 8'd247) lumi <= lumi + 8'd8;
                4'd3:  if(contrast <= 8'd247) contrast <= contrast + 8'd8;
                4'd4:  if(temper <= 8'd247) temper <= temper + 8'd8;
                4'd5:  if(tint <= 8'd247) tint <= tint + 8'd8;
                4'd6:  style_i <= (style_i == 3'd4) ? 3'd0 : style_i + 3'd1;
                4'd7:  if(strength <= 8'd239) strength <= strength + 8'd16;
                4'd8:  audio_sel <= (audio_sel == 2'd2) ? 2'd0 : audio_sel + 2'd1;
                4'd9:  audio_color <= ~audio_color;
                4'd10: txt_color <= ~txt_color;
                4'd11: txt_spd <= (txt_spd == 2'd2) ? 2'd0 : txt_spd + 2'd1;
                4'd12: txt_x <= (txt_x >= 13'd160) ? 13'd160 : txt_x + 13'd16;
                default: txt_y <= (txt_y >= 13'd448) ? 13'd448 : txt_y + 13'd16;
            endcase
        end
    end
end

always @(posedge clk) begin
    if(reset) begin
        menu_out_vsync <= 1'b0;
        menu_out_hsync <= 1'b0;
        menu_out_de    <= 1'b0;
        menu_out_xcnt  <= 13'd0;
        menu_out_ycnt  <= 13'd0;
        menu_out_rgb   <= 24'd0;
    end
    else begin
        menu_out_vsync <= menu_in_vsync;
        menu_out_hsync <= menu_in_hsync;
        menu_out_de    <= menu_in_de;
        menu_out_xcnt  <= menu_in_xcnt;
        menu_out_ycnt  <= menu_in_ycnt;
        menu_out_rgb   <= pix_rgb;
    end
end

endmodule
