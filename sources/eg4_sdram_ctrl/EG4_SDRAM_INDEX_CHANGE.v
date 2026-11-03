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
// Module Name: EG4_SDRAM_INDEX_CHANGE
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

module EG4_SDRAM_INDEX_CHANGE #(
    parameter                   CLK_FREQ                    = 150_000_000
)(
    input   wire                clk                         ,
    input   wire                reset                       ,

    input   wire                sdram_index_change_auto     ,// auto : 1 ; manual : 0;
    input   wire    [7:0]       sdram_index_change_time     ,// auto change frame rate 
    input   wire                sdram_index_change_flag     ,// manual change
    input   wire                sdram_picture_done          ,// 转场结束，再换当前图

    input   wire    [2:0]       sdram_set_index_max         ,

    output  reg                 sdram_picturex_change       ,
    output  reg     [2:0]       sdram_picture1_index        ,
    output  reg     [2:0]       sdram_picture2_index        
);

localparam integer HDMI_HTOTAL = 2200;
localparam integer HDMI_VTOTAL = 1125;

reg                             sdram_index_change_auto_r   ;
reg     [7:0]                   sdram_index_change_time_r   ;
reg                             sdram_index_change_flag_r   ;
reg     [2:0]                   sdram_set_index_max_r       ;

reg     [12:0]                  hdmi_xcnt                   = 0;
reg     [12:0]                  hdmi_vcnt                   = 0;
reg                             hdmi_vsync_flag             = 0;
reg     [7:0]                   hdmi_vsync_cnt              = 0;
reg                             hdmi_vsync_auto_flag        ;

reg     [2:0]                   hdmi_dis_index1             ;
wire    [2:0]                   hdmi_dis_index2             ;
reg                             picture_done_d              ;
wire                            picture_done_pos            ;

assign picture_done_pos = sdram_picture_done & ~picture_done_d;

always@(posedge clk) begin
    sdram_index_change_auto_r <= sdram_index_change_auto;
    sdram_index_change_time_r <= sdram_index_change_time;
    sdram_index_change_flag_r <= sdram_index_change_flag;

    sdram_set_index_max_r <= sdram_set_index_max;
end

always@(posedge clk) begin
    hdmi_xcnt <= hdmi_xcnt == HDMI_HTOTAL - 1'b1 ? 13'd0 : hdmi_xcnt + 1'b1;
    hdmi_vcnt <= hdmi_xcnt == HDMI_HTOTAL - 1'b1 && hdmi_vcnt == HDMI_VTOTAL - 1'b1 ? 13'd0 : (hdmi_xcnt == HDMI_HTOTAL - 1'b1 ? hdmi_vcnt + 1'b1 : hdmi_vcnt);
end

always@(posedge clk) begin
    hdmi_vsync_flag <= hdmi_xcnt == HDMI_HTOTAL - 1'b1 && hdmi_vcnt == HDMI_VTOTAL - 1'b1;
end

always@(posedge clk) begin
    if(reset) begin
        hdmi_vsync_cnt <= 8'd0;
    end
    else if(hdmi_vsync_flag && hdmi_vsync_cnt == sdram_index_change_time_r - 1'b1) begin
        hdmi_vsync_cnt <= 8'd0;
    end
    else if(hdmi_vsync_flag) begin
        hdmi_vsync_cnt <= hdmi_vsync_cnt + 1'b1;
    end

    hdmi_vsync_auto_flag <= hdmi_vsync_flag && hdmi_vsync_cnt == sdram_index_change_time_r - 1'b1;
end


always@(posedge clk) begin
    if(reset) begin
        hdmi_dis_index1 <= 3'd0;
        picture_done_d  <= 1'b0;
    end
    else begin
        picture_done_d <= sdram_picture_done;
        // 切图脉冲只启动转场。当前图留在旧槽，等转场结束再前进，避免先跳到下一张。
        if(picture_done_pos && hdmi_dis_index1 == sdram_set_index_max_r - 1'b1) begin
            hdmi_dis_index1 <= 3'd0;
        end
        else if(picture_done_pos) begin
            hdmi_dis_index1 <= hdmi_dis_index1 + 1'b1;
        end
    end
end

// always@(posedge clk) begin
//     if(reset) begin
//         hdmi_dis_index2 <= 3'd1;
//     end
//     else if(sdram_index_change_auto_r == 1'b1 && hdmi_vsync_auto_flag && hdmi_dis_index1 == sdram_set_index_max_r - 1'b1) begin
//         hdmi_dis_index2 <= 3'd1;
//     end
//     else if(sdram_index_change_auto_r == 1'b1 && hdmi_vsync_auto_flag) begin
//         hdmi_dis_index2 <= hdmi_dis_index1 + 1'b1;
//     end
//     else if(sdram_index_change_auto_r == 1'b0 && sdram_index_change_flag_r && hdmi_dis_index1 == sdram_set_index_max_r - 1'b1) begin
//         hdmi_dis_index2 <= 3'd1;
//     end
//     else if(sdram_index_change_auto_r == 1'b0 && sdram_index_change_flag_r) begin
//         hdmi_dis_index2 <= hdmi_dis_index1 + 1'b1;
//     end
// end

assign hdmi_dis_index2 = (hdmi_dis_index1 == sdram_set_index_max_r - 1'b1) ? 3'd0 : hdmi_dis_index1 + 1'b1;

always@(posedge clk) begin
    sdram_picture1_index <= hdmi_dis_index1;
    sdram_picture2_index <= hdmi_dis_index2;
end


/*----------------------------------------------------------*/

//
wire                            change_flag                 ;
reg                             change_hold                 ;
reg     [3:0]                   change_cnt                  ;

assign change_flag = sdram_index_change_auto_r ? hdmi_vsync_auto_flag : sdram_index_change_flag_r;


always@(posedge clk) begin
    if(reset) begin
        change_hold <= 1'b0;
    end
    else if(change_hold && change_cnt == 4'd15) begin
        change_hold <= 1'b0;
    end
    else if(change_flag) begin
        change_hold <= 1'b1;
    end
end

always@(posedge clk) begin
    if(change_hold) begin
        change_cnt <= change_cnt + 1'b1;
    end
    else begin
        change_cnt <= 4'd0;
    end
end

always@(posedge clk) begin
    sdram_picturex_change <= change_hold;
end


endmodule
