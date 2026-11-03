`timescale 1ns / 1ps

// 异步电平打两拍。复位时输出 0。
module level_sync (
    input   wire                clk                         ,
    input   wire                rst                         ,
    input   wire                din                         ,
    output  wire                dout
);

reg     [1:0]                   sh                          ;

always @(posedge clk) begin
    if(rst)
        sh <= 2'b00;
    else
        sh <= {sh[0], din};
end

assign dout = sh[1];

endmodule
