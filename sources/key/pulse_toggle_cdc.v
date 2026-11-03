`timescale 1ns / 1ps

// 源时钟上的单拍脉冲，用翻转同步到目标时钟，再还原成一拍。
module pulse_toggle_cdc (
    input   wire                src_clk                     ,
    input   wire                src_rst                     ,
    input   wire                src_pulse                   ,
    input   wire                dst_clk                     ,
    input   wire                dst_rst                     ,
    output  wire                dst_pulse
);

reg                             src_tog                     ;
reg                             src_d                       ;
reg     [2:0]                   dst_sync                    ;

// 只认上升沿。按键 flag 若多拍为高，每拍都翻转会在 50 MHz 侧连出一串切歌脉冲。
always @(posedge src_clk) begin
    if(src_rst) begin
        src_tog <= 1'b0;
        src_d   <= 1'b0;
    end
    else begin
        src_d <= src_pulse;
        if(src_pulse && !src_d)
            src_tog <= ~src_tog;
    end
end

always @(posedge dst_clk) begin
    if(dst_rst)
        dst_sync <= 3'd0;
    else
        dst_sync <= {dst_sync[1:0], src_tog};
end

assign dst_pulse = dst_sync[2] ^ dst_sync[1];

endmodule
