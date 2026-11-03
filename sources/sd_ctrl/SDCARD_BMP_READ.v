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
// Create Date: 2026/10/11 09:21:17
// Design Name: 
// Module Name: SDCARD_BMP_READ
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SDCARD_BMP_READ #(
    parameter                   CLK_FREQ                    = 50_000_000
)(
    input   wire                clk                         ,
    input   wire                reset                       ,

    input   wire                sd_index_init_done          ,

    input   wire                sd_bmp_init_flag            ,
    output  reg                 sd_bmp_init_done            ,

    input   wire                sd_bmp_Structures_flag      ,
    input   wire    [3:0]       sd_bmp_Structures_cnt       ,
    input   wire    [81:0]      sd_bmp_Structures_data      ,//24+32+13+13

    output  reg                 sd_bmp_r_req                ,
    output  reg     [31:0]      sd_bmp_r_addr               ,
    input   wire                sd_bmp_r_ack                ,

    input   wire                sd_bmp_r_start              ,
    input   wire                sd_bmp_r_dv                 ,
    input   wire    [7:0]       sd_bmp_r_data               ,
    input   wire                sd_bmp_r_end                ,
    input   wire    [8:0]       sd_bmp_r_cnt                ,
    input   wire                sd_bmp_r_err                ,

    output  reg                 sd_bmp_out_start            ,
    output  reg     [3:0]       sd_bmp_out_index            ,
    output  reg     [12:0]      sd_bmp_out_width            ,
    output  reg     [12:0]      sd_bmp_out_height           ,
    output  reg                 sd_bmp_out_dv               ,
    output  reg     [23:0]      sd_bmp_out_data             ,
    output  reg     [12:0]      sd_bmp_out_xcnt             ,
    output  reg     [12:0]      sd_bmp_out_ycnt             ,

    input   wire    [2:0]       sd_bmp_size_index1          ,
    input   wire    [2:0]       sd_bmp_size_index2          ,
    output  wire    [12:0]      sd_bmp_size_width1          ,
    output  wire    [12:0]      sd_bmp_size_height1         ,
    output  wire    [12:0]      sd_bmp_size_width2          ,
    output  wire    [12:0]      sd_bmp_size_height2         ,

    output  wire    [4:0]       sd_bmp_group_end
);

reg                             sd_index_init_done_r        ;
reg                             sd_bmp_init_flag_r          ;

reg     [81:0]                  sdpram_cmd_buffer0          ;
reg     [81:0]                  sdpram_cmd_buffer1          ;
reg     [81:0]                  sdpram_cmd_buffer2          ;
reg     [81:0]                  sdpram_cmd_buffer3          ;
reg     [81:0]                  sdpram_cmd_buffer4          ;
reg     [81:0]                  sdpram_cmd_buffer5          ;
reg     [81:0]                  sdpram_cmd_buffer6          ;
reg     [81:0]                  sdpram_cmd_buffer7          ;
reg     [81:0]                  sdpram_cmd_buffer8          ;
reg     [81:0]                  sdpram_cmd_buffer9          ;
reg     [81:0]                  sdpram_cmd_buffer10         ;
reg     [81:0]                  sdpram_cmd_buffer11         ;
reg     [81:0]                  sdpram_cmd_buffer12         ;
reg     [81:0]                  sdpram_cmd_buffer13         ;
reg     [81:0]                  sdpram_cmd_buffer14         ;
reg     [81:0]                  sdpram_cmd_buffer15         ;

reg                             sdpram_cmd_wea              ;
reg     [81:0]                  sdpram_cmd_dina             ;
reg     [3:0]                   sdpram_cmd_addra            ;
reg     [4:0]                   sdpram_cmd_addrb            ;
reg     [81:0]                  sdpram_cmd_doutb            ;
reg     [81:0]                  sdpram_cmd_doutb_r          ;

wire                            sdpram_cmd_rd_en            ;
reg                             sdpram_cmd_rd_en_r          ;
reg                             sdpram_cmd_rd_en_rr         ;

reg     [4:0]                   sdpram_cmd_addr_end         ;

reg                             sdpram_cmd_nempty           ;
reg                             sdpram_cmd_nempty_r         ;
wire                            sdpram_cmd_nempty_pos       ;
reg     [3:0]                   sdpram_cmd_nempty_pos_r4    ;

reg     [23:0]                  type_bmp_saddr              ;
reg     [31:0]                  type_bmp_blength            ;
reg     [12:0]                  type_bmp_width              ;
reg     [12:0]                  type_bmp_height             ;

reg                             bmp_start                   ;
reg                             bmp_dv                      ;
reg     [7:0]                   bmp_data                    ;
reg                             bmp_end                     ;
reg     [8:0]                   bmp_cnt                     ;
reg                             bmp_err                     ;

/*----------------------------------------------------------*/

reg                             bmp_read_sop                ;
reg                             bmp_read_hold               ;
reg                             bmp_read_eop                ;

reg                             bmp_read_req_start          ;

reg     [22:0]                  bmp_read_section_nub        ;
reg     [22:0]                  bmp_read_section_cnt        ;

/*----------------------------------------------------------*/

parameter                       STA_IDLE                    = 3'd0  ,
                                STA_REQ                     = 3'd1  ,
                                STA_DATA                    = 3'd2  ,
                                STA_DONE                    = 3'd3  ,
                                STA_ERR                     = 3'd4  ;

reg     [2:0]                   state                       ;
reg     [2:0]                   state_r                     ;
reg     [2:0]                   state_rr                    ;

reg                             state_change_flag           ;

reg     [5:0]                   bmp_read_head_cnt           ;
reg     [31:0]                  bmp_read_payload_cnt        ;

reg                             bmp_read_head_dv            ;
reg     [7:0]                   bmp_read_head_data          ;

reg                             bmp_read_payload_hold       ;
reg                             bmp_read_payload_dv         ;
reg     [7:0]                   bmp_read_payload_data       ;

always@(posedge clk) begin
    sd_index_init_done_r    <= sd_index_init_done   ;
    sd_bmp_init_flag_r      <= sd_bmp_init_flag     ;

    bmp_start   <= sd_bmp_r_start   ;
    bmp_dv      <= sd_bmp_r_dv      ;
    bmp_data    <= sd_bmp_r_data    ;
    bmp_end     <= sd_bmp_r_end     ;
    bmp_cnt     <= sd_bmp_r_cnt     ;
    bmp_err     <= sd_bmp_r_err     ;
end



always@(posedge clk) begin
    if(reset) begin
        sdpram_cmd_nempty <= 1'b0;
    end
    else if(bmp_read_eop) begin
        sdpram_cmd_nempty <= 1'b0;
    end
    else if(!sdpram_cmd_nempty && sd_index_init_done_r && sdpram_cmd_addrb != sdpram_cmd_addr_end) begin
        sdpram_cmd_nempty <= 1'b1;
    end
    sdpram_cmd_nempty_r <= sdpram_cmd_nempty;

    sdpram_cmd_nempty_pos_r4 <= {sdpram_cmd_nempty_pos_r4[2:0],sdpram_cmd_nempty_pos};
end

assign sdpram_cmd_nempty_pos = sdpram_cmd_nempty & !sdpram_cmd_nempty_r;


always@(posedge clk) begin
    type_bmp_saddr     <= sdpram_cmd_rd_en_rr ? sdpram_cmd_doutb_r[81:58] : type_bmp_saddr        ;
    type_bmp_blength   <= sdpram_cmd_rd_en_rr ? sdpram_cmd_doutb_r[57:26] : type_bmp_blength      ;
    type_bmp_width     <= sdpram_cmd_rd_en_rr ? sdpram_cmd_doutb_r[25:13] : type_bmp_width        ;
    type_bmp_height    <= sdpram_cmd_rd_en_rr ? sdpram_cmd_doutb_r[12:0]  : type_bmp_height       ;
end

always@(posedge clk) begin

    bmp_read_sop <= sdpram_cmd_nempty_pos_r4[1];

    if(reset) begin
        bmp_read_hold <= 1'b0;
    end
    else if(bmp_read_eop) begin
        bmp_read_hold <= 1'b0;
    end
    else if(bmp_read_sop) begin
        bmp_read_hold <= 1'b1;
    end

    bmp_read_eop <= bmp_read_hold && bmp_read_section_cnt == bmp_read_section_nub - 1'b1 && bmp_end;
end

always@(posedge clk) begin
    if(type_bmp_blength[8:0] == 9'd0) begin
        bmp_read_section_nub <= type_bmp_blength[31:9];
    end
    else if(type_bmp_blength[8:0] != 9'd0) begin
        bmp_read_section_nub <= type_bmp_blength[31:9] + 1'b1;
    end
end

always@(posedge clk) begin
    if(reset) begin
        bmp_read_section_cnt <= 23'd0;
    end
    else if(bmp_read_eop) begin
        bmp_read_section_cnt <= 23'd0;
    end
    else if(bmp_read_hold && bmp_end) begin
        bmp_read_section_cnt <= bmp_read_section_cnt + 1'b1;
    end
end

always@(posedge clk) begin
    if(bmp_read_sop) begin
        bmp_read_req_start <= 1'b1;
    end
    else if(bmp_read_hold && bmp_read_section_cnt < bmp_read_section_nub && state == STA_DONE) begin
        bmp_read_req_start <= 1'b1;
    end
    else begin
        bmp_read_req_start <= 1'b0;
    end
end

always@(posedge clk) begin
    if(reset) begin
        state <= STA_IDLE;
    end
    else begin
        case(state)
            STA_IDLE    : begin 
                if(bmp_read_req_start) begin 
                    state <= STA_REQ;
                end 
            end
            STA_REQ     : begin if(sd_bmp_r_ack)             begin state <= STA_DATA     ;end end
            STA_DATA    : begin if(bmp_read_hold && bmp_end) begin state <= STA_DONE     ;end end
            STA_DONE    : begin                                    state <= STA_IDLE     ;end
            default     : begin                                    state <= STA_IDLE     ;end
        endcase
    end

    state_r <= state;
    state_rr <= state_r;

    state_change_flag <= state_rr != state_r;
end

always@(posedge clk) begin
    if(reset) begin
        sd_bmp_r_req <= 1'b0;
    end
    else if(sd_bmp_r_ack) begin
        sd_bmp_r_req <= 1'b0;
    end
    else if(bmp_read_req_start) begin
        sd_bmp_r_req <= 1'b1;
    end
end

always@(posedge clk) begin
    if(reset) begin
        sd_bmp_r_addr <= 32'd0;
    end
    else if(bmp_read_sop) begin
        sd_bmp_r_addr <= {8'd0,type_bmp_saddr};
    end
    else if(bmp_read_hold && bmp_end) begin
        sd_bmp_r_addr <= sd_bmp_r_addr + 1'b1;
    end
end

/*----------------------------------------------------------*/

always@(posedge clk) begin
    if(sd_bmp_Structures_flag) begin
        sdpram_cmd_dina     <= sd_bmp_Structures_data;
        sdpram_cmd_wea      <= 1'b1;
        sdpram_cmd_addra    <= sd_bmp_Structures_cnt;
    end
    else begin
        sdpram_cmd_wea      <= 1'b0;
    end
end


assign sdpram_cmd_rd_en = sdpram_cmd_nempty_pos;

always@(posedge clk) begin
    sdpram_cmd_rd_en_r <= sdpram_cmd_rd_en;
    sdpram_cmd_rd_en_rr <= sdpram_cmd_rd_en_r;
end

always@(posedge clk) begin
    if(sdpram_cmd_wea) begin
        case(sdpram_cmd_addra)
            4'd0  :  sdpram_cmd_buffer0     <= sdpram_cmd_dina;
            4'd1  :  sdpram_cmd_buffer1     <= sdpram_cmd_dina;
            4'd2  :  sdpram_cmd_buffer2     <= sdpram_cmd_dina;
            4'd3  :  sdpram_cmd_buffer3     <= sdpram_cmd_dina;
            4'd4  :  sdpram_cmd_buffer4     <= sdpram_cmd_dina;
            4'd5  :  sdpram_cmd_buffer5     <= sdpram_cmd_dina;
            4'd6  :  sdpram_cmd_buffer6     <= sdpram_cmd_dina;
            4'd7  :  sdpram_cmd_buffer7     <= sdpram_cmd_dina;
            4'd8  :  sdpram_cmd_buffer8     <= sdpram_cmd_dina;
            4'd9  :  sdpram_cmd_buffer9     <= sdpram_cmd_dina;
            4'd10 :  sdpram_cmd_buffer10    <= sdpram_cmd_dina;
            4'd11 :  sdpram_cmd_buffer11    <= sdpram_cmd_dina;
            4'd12 :  sdpram_cmd_buffer12    <= sdpram_cmd_dina;
            4'd13 :  sdpram_cmd_buffer13    <= sdpram_cmd_dina;
            4'd14 :  sdpram_cmd_buffer14    <= sdpram_cmd_dina;
            4'd15 :  sdpram_cmd_buffer15    <= sdpram_cmd_dina;
        endcase
    end

    if(sdpram_cmd_rd_en) begin
        case(sdpram_cmd_addrb)
            4'd0  : sdpram_cmd_doutb <= sdpram_cmd_buffer0 ;
            4'd1  : sdpram_cmd_doutb <= sdpram_cmd_buffer1 ;
            4'd2  : sdpram_cmd_doutb <= sdpram_cmd_buffer2 ;
            4'd3  : sdpram_cmd_doutb <= sdpram_cmd_buffer3 ;
            4'd4  : sdpram_cmd_doutb <= sdpram_cmd_buffer4 ;
            4'd5  : sdpram_cmd_doutb <= sdpram_cmd_buffer5 ;
            4'd6  : sdpram_cmd_doutb <= sdpram_cmd_buffer6 ;
            4'd7  : sdpram_cmd_doutb <= sdpram_cmd_buffer7 ;
            4'd8  : sdpram_cmd_doutb <= sdpram_cmd_buffer8 ;
            4'd9  : sdpram_cmd_doutb <= sdpram_cmd_buffer9 ;
            4'd10 : sdpram_cmd_doutb <= sdpram_cmd_buffer10;
            4'd11 : sdpram_cmd_doutb <= sdpram_cmd_buffer11;
            4'd12 : sdpram_cmd_doutb <= sdpram_cmd_buffer12;
            4'd13 : sdpram_cmd_doutb <= sdpram_cmd_buffer13;
            4'd14 : sdpram_cmd_doutb <= sdpram_cmd_buffer14;
            4'd15 : sdpram_cmd_doutb <= sdpram_cmd_buffer15;
        endcase
    end

    sdpram_cmd_doutb_r <= sdpram_cmd_doutb;
end

// simple_dual_ram #(
//     .RAM_WIDTH                  (82                         ),
//     .RAM_DEPTH                  (16                         ),
//     .PERFORMENCE                ("LOW"                      ),
//     .INIT_FILE                  (""                         )
// )sdpram_cmd(
//     .clka                       (clk                        ),
//     .wea                        (sdpram_cmd_wea             ),
//     .dina                       (sdpram_cmd_dina            ),  
//     .addra                      (sdpram_cmd_addra           ),
//     .addrb                      (sdpram_cmd_addrb           ),
//     .doutb                      (sdpram_cmd_doutb           )
// );

assign sd_bmp_group_end = sdpram_cmd_addr_end;

always@(posedge clk) begin
    if(reset) begin
        sdpram_cmd_addr_end <= 5'd8;
    end
    else if(sd_bmp_init_flag_r && sd_bmp_init_done == 1'b1) begin
        sdpram_cmd_addr_end <= (sdpram_cmd_addr_end == 5'd8) ? 5'd16 : 5'd8;
    end
end

always@(posedge clk) begin
    if(reset) begin
        sdpram_cmd_addrb <= 5'd0;
    end
    else if(sd_bmp_init_flag_r && sd_bmp_init_done == 1'b1) begin
        sdpram_cmd_addrb <= (sdpram_cmd_addr_end == 5'd8) ? 5'd8 : 5'd0;
    end
    else if(sdpram_cmd_rd_en) begin
        sdpram_cmd_addrb <= sdpram_cmd_addrb + 1'b1;
    end
end

/*----------------------------------------------------------*/

always@(posedge clk) begin
    if(bmp_read_sop) begin
        bmp_read_head_cnt <= 6'd0;
    end
    else if(bmp_read_hold && bmp_dv && bmp_read_head_cnt < 6'd54) begin
        bmp_read_head_cnt <= bmp_read_head_cnt + 1'b1;
    end
end

always@(posedge clk) begin
    if(bmp_read_sop) begin
        bmp_read_payload_cnt <= 32'd0;
    end
    else if(bmp_read_hold && bmp_dv && bmp_read_head_cnt == 6'd54) begin
        bmp_read_payload_cnt <= bmp_read_payload_cnt + 1'b1;
    end
end

/*----------------------------------------------------------*/

always@(posedge clk) begin
    if(bmp_read_sop) begin
        bmp_read_payload_hold <= 1'b0;
    end
    else if(bmp_read_hold && bmp_dv && bmp_read_payload_cnt == type_bmp_blength - 6'd54 - 1'b1) begin
        bmp_read_payload_hold <= 1'b0;
    end
    else if(bmp_read_hold && bmp_dv && bmp_read_head_cnt == 6'd53) begin
        bmp_read_payload_hold <= 1'b1;
    end
end

always@(posedge clk) begin
    if(bmp_read_payload_hold && bmp_dv) begin
        bmp_read_payload_dv <= 1'b1;
        bmp_read_payload_data <= bmp_data;
    end
    else begin
        bmp_read_payload_dv <= 1'b0;
    end
end



/*----------------------------------------------------------*/

reg     [1:0]                   bmp_read_bgr_cnt            ;
reg                             bmp_read_pixel_dv           ;
reg     [23:0]                  bmp_read_pixel_data         ;

reg     [7:0]                   skid_mem [0:15]             ;
reg     [3:0]                   skid_w                      ;
reg     [3:0]                   skid_r                      ;
reg     [4:0]                   skid_n                      ;
reg     [1:0]                   pad_left                    ;
reg     [12:0]                  src_x                       ;
reg     [12:0]                  emit_x                      ;
reg     [12:0]                  emit_y                      ;
reg     [12:0]                  black_left                  ;
reg     [12:0]                  file_w_l                    ;
reg     [12:0]                  file_h_l                    ;
reg     [12:0]                  use_w_l                     ;
reg     [12:0]                  use_h_l                     ;
reg                             tail_arm                    ;
reg     [12:0]                  slot_w [0:7]                ;
reg     [12:0]                  slot_h [0:7]                ;
integer                         slot_i                      ;

function [12:0] clamp_w;
    input [12:0] w;
    reg   [12:0] aligned;
    begin
        if(w > 13'd640)
            clamp_w = 13'd640;
        else if(w < 13'd4)
            clamp_w = 13'd4;
        else begin
            aligned = {w[12:2], 2'b00};
            clamp_w = (aligned < 13'd4) ? 13'd4 : aligned;
        end
    end
endfunction

function [12:0] clamp_h;
    input [12:0] h;
    begin
        if(h == 13'd0)
            clamp_h = 13'd1;
        else if(h > 13'd480)
            clamp_h = 13'd480;
        else
            clamp_h = h;
    end
endfunction

function [1:0] row_pad;
    input [12:0] w;
    begin
        case(w[1:0])
            2'd1: row_pad = 2'd1;
            2'd2: row_pad = 2'd2;
            2'd3: row_pad = 2'd3;
            default: row_pad = 2'd0;
        endcase
    end
endfunction

wire [12:0] raw_w_now = sdpram_cmd_rd_en_rr ? sdpram_cmd_doutb_r[25:13] : type_bmp_width;
wire [12:0] raw_h_now = sdpram_cmd_rd_en_rr ? sdpram_cmd_doutb_r[12:0]  : type_bmp_height;
wire [3:0]  pic_index = sdpram_cmd_addrb[3:0] - 4'd1;
wire        skid_has  = (skid_n != 5'd0);
wire [7:0]  skid_byte = skid_mem[skid_r];
wire        take_byte = (black_left == 13'd0) && skid_has;

assign sd_bmp_size_width1  = slot_w[sd_bmp_size_index1];
assign sd_bmp_size_height1 = slot_h[sd_bmp_size_index1];
assign sd_bmp_size_width2  = slot_w[sd_bmp_size_index2];
assign sd_bmp_size_height2 = slot_h[sd_bmp_size_index2];

// 宽高限幅到 640x480，宽按 4 像素对齐。文件行比限幅宽时丢掉多余像素和行尾填充，
// 比限幅窄时补黑，写出的点数和送给 SDRAM 的宽高一致。每张图的尺寸按槽保存，读哪张用哪张。
always@(posedge clk) begin
    if(reset) begin
        for(slot_i = 0; slot_i < 8; slot_i = slot_i + 1) begin
            slot_w[slot_i] <= 13'd640;
            slot_h[slot_i] <= 13'd480;
        end
        skid_w <= 4'd0;
        skid_r <= 4'd0;
        skid_n <= 5'd0;
        pad_left <= 2'd0;
        src_x <= 13'd0;
        emit_x <= 13'd0;
        emit_y <= 13'd0;
        black_left <= 13'd0;
        file_w_l <= 13'd640;
        file_h_l <= 13'd480;
        use_w_l <= 13'd640;
        use_h_l <= 13'd480;
        tail_arm <= 1'b0;
        bmp_read_bgr_cnt <= 2'd0;
        bmp_read_pixel_dv <= 1'b0;
        sd_bmp_out_dv <= 1'b0;
        sd_bmp_out_data <= 24'd0;
        sd_bmp_out_xcnt <= 13'd0;
        sd_bmp_out_ycnt <= 13'd0;
    end
    else begin
        sd_bmp_out_dv <= 1'b0;
        if(bmp_read_sop) begin
            skid_w <= 4'd0;
            skid_r <= 4'd0;
            skid_n <= 5'd0;
            pad_left <= 2'd0;
            src_x <= 13'd0;
            emit_x <= 13'd0;
            emit_y <= 13'd0;
            black_left <= 13'd0;
            file_w_l <= (raw_w_now == 13'd0) ? 13'd1 : raw_w_now;
            file_h_l <= (raw_h_now == 13'd0) ? 13'd1 : raw_h_now;
            use_w_l <= clamp_w(raw_w_now);
            use_h_l <= clamp_h(raw_h_now);
            tail_arm <= 1'b0;
            bmp_read_bgr_cnt <= 2'd0;
            slot_w[pic_index[2:0]] <= clamp_w(raw_w_now);
            slot_h[pic_index[2:0]] <= clamp_h(raw_h_now);
        end
        else if(black_left != 13'd0 && emit_y < use_h_l) begin
            sd_bmp_out_dv <= 1'b1;
            sd_bmp_out_data <= 24'd0;
            sd_bmp_out_xcnt <= emit_x;
            sd_bmp_out_ycnt <= emit_y;
            if(emit_x + 13'd1 == use_w_l) begin
                emit_x <= 13'd0;
                black_left <= 13'd0;
                if(emit_y + 13'd1 == use_h_l || emit_y + 13'd1 == file_h_l)
                    emit_y <= use_h_l;
                else
                    emit_y <= emit_y + 13'd1;
            end
            else begin
                emit_x <= emit_x + 13'd1;
                black_left <= black_left - 13'd1;
            end
            if(bmp_read_payload_dv && skid_n < 5'd16) begin
                skid_mem[skid_w] <= bmp_read_payload_data;
                skid_w <= skid_w + 4'd1;
                skid_n <= skid_n + 5'd1;
            end
        end
        else if(take_byte) begin
            skid_r <= skid_r + 4'd1;
            skid_n <= skid_n - 5'd1;
            if(bmp_read_payload_dv && skid_n < 5'd16) begin
                skid_mem[skid_w] <= bmp_read_payload_data;
                skid_w <= skid_w + 4'd1;
                skid_n <= skid_n;
            end
            if(pad_left != 2'd0) begin
                pad_left <= pad_left - 2'd1;
            end
            else begin
                if(bmp_read_bgr_cnt == 2'd0)
                    bmp_read_pixel_data[7:0] <= skid_byte;
                else if(bmp_read_bgr_cnt == 2'd1)
                    bmp_read_pixel_data[15:8] <= skid_byte;
                else
                    bmp_read_pixel_data[23:16] <= skid_byte;
                if(bmp_read_bgr_cnt == 2'd2) begin
                    bmp_read_bgr_cnt <= 2'd0;
                    bmp_read_pixel_dv <= 1'b1;
                    if(emit_y < use_h_l && src_x < use_w_l) begin
                        sd_bmp_out_dv <= 1'b1;
                        sd_bmp_out_data <= {skid_byte, bmp_read_pixel_data[15:0]};
                        sd_bmp_out_xcnt <= src_x;
                        sd_bmp_out_ycnt <= emit_y;
                        emit_x <= src_x + 13'd1;
                    end
                    if(src_x + 13'd1 == file_w_l) begin
                        src_x <= 13'd0;
                        pad_left <= row_pad(file_w_l);
                        if((emit_y < use_h_l) && (src_x + 13'd1 < use_w_l))
                            black_left <= use_w_l - (src_x + 13'd1);
                        else if(emit_y < use_h_l) begin
                            if(emit_y + 13'd1 == use_h_l || emit_y + 13'd1 == file_h_l)
                                emit_y <= use_h_l;
                            else
                                emit_y <= emit_y + 13'd1;
                        end
                    end
                    else begin
                        src_x <= src_x + 13'd1;
                    end
                end
                else begin
                    bmp_read_bgr_cnt <= bmp_read_bgr_cnt + 2'd1;
                    bmp_read_pixel_dv <= 1'b0;
                end
            end
        end
        else if(bmp_read_payload_dv && skid_n < 5'd16) begin
            skid_mem[skid_w] <= bmp_read_payload_data;
            skid_w <= skid_w + 4'd1;
            skid_n <= skid_n + 5'd1;
            bmp_read_pixel_dv <= 1'b0;
        end
        else if(tail_arm && skid_n == 5'd0 && black_left == 13'd0 && emit_y < use_h_l) begin
            // 文件提前结束时把限幅画面余下的点涂黑，避免右边留下上一张。
            sd_bmp_out_dv <= 1'b1;
            sd_bmp_out_data <= 24'd0;
            sd_bmp_out_xcnt <= emit_x;
            sd_bmp_out_ycnt <= emit_y;
            bmp_read_pixel_dv <= 1'b0;
            if(emit_x + 13'd1 == use_w_l) begin
                emit_x <= 13'd0;
                if(emit_y + 13'd1 == use_h_l)
                    emit_y <= use_h_l;
                else
                    emit_y <= emit_y + 13'd1;
            end
            else
                emit_x <= emit_x + 13'd1;
        end
        else begin
            bmp_read_pixel_dv <= 1'b0;
        end
        if(bmp_read_sop)
            tail_arm <= 1'b0;
        else if(bmp_read_eop || (!bmp_read_payload_hold && bmp_read_head_cnt >= 6'd54 && bmp_read_hold))
            tail_arm <= 1'b1;
    end
end

/*----------------------------------------------------------*/
`ifndef SIM_MODE
always@(posedge clk) begin
    if(reset) begin
        sd_bmp_init_done    <= 1'b0;
    end
    else if(!sd_index_init_done_r || sd_bmp_init_flag_r) begin
        sd_bmp_init_done    <= 1'b0;
    end
    else if(bmp_read_eop && sdpram_cmd_addrb == sdpram_cmd_addr_end) begin
        sd_bmp_init_done    <= 1'b1;
    end
end

`else
always@(posedge clk) begin
    if(reset) begin
        sd_bmp_init_done    <= 1'b0;
    end
    else if(!sd_index_init_done_r || sd_bmp_init_flag_r) begin
        sd_bmp_init_done    <= 1'b0;
    end 
    else if(bmp_read_eop && sdpram_cmd_addrb == 'd1) begin
        sd_bmp_init_done    <= 1'b1;
    end
end

`endif 

always@(posedge clk) begin
    sd_bmp_out_start    <= bmp_read_sop;
    if(reset) begin
        sd_bmp_out_index    <= 4'd0;
        sd_bmp_out_width    <= 13'd0;
        sd_bmp_out_height   <= 13'd0;
    end
    else if(bmp_read_sop) begin
        sd_bmp_out_index    <= pic_index;
        sd_bmp_out_width    <= clamp_w(raw_w_now);
        sd_bmp_out_height   <= clamp_h(raw_h_now);
    end
end




endmodule
