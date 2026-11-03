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
// Module Name: VPU_SUBSYS_TOP
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

module VPU_SUBSYS_TOP #(
    parameter                   CLK_FREQ                    = 75_000_000
)(
    input   wire                clk                         ,
    input   wire                reset                       ,

    input   wire                menu_power                  ,
    input   wire                menu_up                     ,
    input   wire                menu_down                   ,
    input   wire                menu_left                   ,
    input   wire                menu_right                  ,
    input   wire                menu_center                 ,

    input   wire    [12:0]      vpu_valid_width             ,
    input   wire    [12:0]      vpu_valid_height            ,

    input   wire                vpu_audio_valid             ,
    input   wire    [15:0]      vpu_audio_data              ,

    input   wire                vpu_in_pchange              ,
    input   wire                vpu_in_vsync                ,
    input   wire                vpu_in_hsync                ,
    input   wire                vpu_in_de                   ,
    input   wire    [12:0]      vpu_in_xcnt                 ,
    input   wire    [12:0]      vpu_in_ycnt                 ,
    input   wire    [23:0]      vpu_in_rgb1                 ,
    input   wire    [23:0]      vpu_in_rgb2                 ,

    output  wire                vpu_out_vsync               ,
    output  wire                vpu_out_hsync               ,
    output  wire                vpu_out_de                  ,
    output  wire    [12:0]      vpu_out_xcnt                ,
    output  wire    [12:0]      vpu_out_ycnt                ,
    output  wire    [23:0]      vpu_out_rgb                 ,
    output  wire                vpu_cut_done                
);

wire                            cut_to_disable              ;
wire    [2:0]                   cut_to_mode_set             ;
wire    [1:0]                   cut_to_speed_set            ;

wire                            dis_eff_disable             ;
wire    [7:0]                   lumi_set_data               ;
wire    [7:0]                   contrast_set_data           ;
wire    [7:0]                   temp_set_data               ;
wire    [7:0]                   tint_set_data               ;

wire                            osd_disable                 ;
wire    [12:0]                  osd_logo_sx                 ;
wire    [12:0]                  osd_logo_sy                 ;

wire    [12:0]                  osd_txt_sx                  ;
wire    [12:0]                  osd_txt_sy                  ;
wire    [12:0]                  osd_txt_x_area              ;
wire    [1:0]                   osd_txt_speed               ;
wire    [1:0]                   osd_color_mode              ;
wire    [23:0]                  osd_color_set               ;
wire                            osd_txt_disable             ;

wire                            osd_txtram_dv               ;
wire    [31:0]                  osd_txtram_data             ;
wire    [10:0]                  osd_txtram_addr             ;

wire                            vpu_audio_disable           ;
wire    [1:0]                   vpu_audio_mode              ;
wire    [1:0]                   vpu_audio_color_mode        ;
wire    [23:0]                  vpu_audio_color_data        ;
wire    [12:0]                  vpu_audio_sx                ;
wire    [12:0]                  vpu_audio_sy                ;

wire                            style_disable               ;
wire    [2:0]                   style_mode                  ;
wire    [7:0]                   style_bin_th                ;
wire    [7:0]                   style_gamma                 ;

/*----------------------------------------------------------*/

wire                            cut_to_out_vsync            ;
wire                            cut_to_out_hsync            ;
wire                            cut_to_out_de               ;
wire    [12:0]                  cut_to_out_xcnt             ;
wire    [12:0]                  cut_to_out_ycnt             ;
wire    [23:0]                  cut_to_out_rgb              ;
wire                            cut_to_out_done             ;
assign vpu_cut_done = cut_to_out_done;

wire                            audio_out_vsync             ;
wire                            audio_out_hsync             ;
wire                            audio_out_de                ;
wire    [12:0]                  audio_out_xcnt              ;
wire    [12:0]                  audio_out_ycnt              ;
wire    [23:0]                  audio_out_rgb               ;

wire                            dis_eff_out_vsync           ;
wire                            dis_eff_out_hsync           ;
wire                            dis_eff_out_de              ;
wire    [12:0]                  dis_eff_out_xcnt            ;
wire    [12:0]                  dis_eff_out_ycnt            ;
wire    [23:0]                  dis_eff_out_rgb             ;

wire                            style_out_vsync             ;
wire                            style_out_hsync             ;
wire                            style_out_de                ;
wire    [12:0]                  style_out_xcnt              ;
wire    [12:0]                  style_out_ycnt              ;
wire    [23:0]                  style_out_rgb               ;

wire                            vpu_scaler_out_vsync        ;
wire                            vpu_scaler_out_hsync        ;
wire                            vpu_scaler_out_de           ;
wire    [12:0]                  vpu_scaler_out_xcnt         ;
wire    [12:0]                  vpu_scaler_out_ycnt         ;
wire    [23:0]                  vpu_scaler_out_rgb          ;

wire                            osd_out_vsync               ;
wire                            osd_out_hsync               ;
wire                            osd_out_de                  ;
wire    [12:0]                  osd_out_xcnt                ;
wire    [12:0]                  osd_out_ycnt                ;
wire    [23:0]                  osd_out_rgb                 ;

assign osd_color_set   = 24'hFFFFFF;
assign osd_txt_disable  = 1'b0;
assign osd_txtram_dv    = 1'b0;
assign osd_txtram_data  = 32'd0;
assign osd_txtram_addr  = 11'd0;
assign vpu_audio_color_data = 24'h00C853;

/*----------------------------------------------------------*/

VPU_CUT_TO VPU_CUT_TO(
    .clk                        (clk                        ),
    .reset                      (reset                      ),

    .cut_to_valid_width         (vpu_valid_width            ),
    .cut_to_valid_height        (vpu_valid_height           ),

    .cut_to_disable             (cut_to_disable             ),

    .cut_to_mode_set            (cut_to_mode_set            ),
    .cut_to_speed_set           (cut_to_speed_set           ),

    .cut_to_in_pchange          (vpu_in_pchange             ),
    .cut_to_in_vsync            (vpu_in_vsync               ),
    .cut_to_in_hsync            (vpu_in_hsync               ),
    .cut_to_in_de               (vpu_in_de                  ),
    .cut_to_in_xcnt             (vpu_in_xcnt                ),
    .cut_to_in_ycnt             (vpu_in_ycnt                ),
    .cut_to_in_rgb1             (vpu_in_rgb1                ),
    .cut_to_in_rgb2             (vpu_in_rgb2                ),

    .cut_to_out_vsync           (cut_to_out_vsync           ),
    .cut_to_out_hsync           (cut_to_out_hsync           ),
    .cut_to_out_de              (cut_to_out_de              ),
    .cut_to_out_xcnt            (cut_to_out_xcnt            ),
    .cut_to_out_ycnt            (cut_to_out_ycnt            ),
    .cut_to_out_rgb             (cut_to_out_rgb             ),
    .cut_to_out_done            (cut_to_out_done            )
);

VPU_display_effect VPU_display_effect(
    .clk                        (clk                        ),
    .reset                      (reset                      ),

    .dis_eff_valid_width        (vpu_valid_width            ),
    .dis_eff_valid_height       (vpu_valid_height           ),

    .dis_eff_disable            (dis_eff_disable            ),

    .lumi_set_data              (lumi_set_data              ),
    .contrast_set_data          (contrast_set_data          ),
    .temp_set_data              (temp_set_data              ),
    .tint_set_data              (tint_set_data              ),

    .dis_eff_in_vsync           (cut_to_out_vsync           ),
    .dis_eff_in_hsync           (cut_to_out_hsync           ),
    .dis_eff_in_de              (cut_to_out_de              ),
    .dis_eff_in_xcnt            (cut_to_out_xcnt            ),
    .dis_eff_in_ycnt            (cut_to_out_ycnt            ),
    .dis_eff_in_rgb             (cut_to_out_rgb             ),

    .dis_eff_out_vsync          (dis_eff_out_vsync          ),
    .dis_eff_out_hsync          (dis_eff_out_hsync          ),
    .dis_eff_out_de             (dis_eff_out_de             ),
    .dis_eff_out_xcnt           (dis_eff_out_xcnt           ),
    .dis_eff_out_ycnt           (dis_eff_out_ycnt           ),
    .dis_eff_out_rgb            (dis_eff_out_rgb            )
);

VPU_style VPU_style(
    .clk                        (clk                        ),
    .reset                      (reset                      ),

    .style_disable              (style_disable              ),
    .style_mode                 (style_mode                 ),
    .style_bin_th               (style_bin_th               ),
    .style_gamma                (style_gamma                ),

    .style_in_vsync             (dis_eff_out_vsync          ),
    .style_in_hsync             (dis_eff_out_hsync          ),
    .style_in_de                (dis_eff_out_de             ),
    .style_in_xcnt              (dis_eff_out_xcnt           ),
    .style_in_ycnt              (dis_eff_out_ycnt           ),
    .style_in_rgb               (dis_eff_out_rgb            ),

    .style_out_vsync            (style_out_vsync            ),
    .style_out_hsync            (style_out_hsync            ),
    .style_out_de               (style_out_de               ),
    .style_out_xcnt             (style_out_xcnt             ),
    .style_out_ycnt             (style_out_ycnt             ),
    .style_out_rgb              (style_out_rgb              )
);

// VPU_Scaler VPU_Scaler(
//     .clk                        (clk                        ),
//     .reset                      (reset                      ),

//     .vpu_scaler_disable         (vpu_scaler_disable         ),
//     .vpu_scaler_valid_width     (vpu_valid_width            ),
//     .vpu_scaler_valid_height    (vpu_valid_height           ),
//     .vpu_scaler_target_width    (vpu_scaler_target_width    ),
//     .vpu_scaler_target_height   (vpu_scaler_target_height   ),

//     .vpu_scaler_in_vsync        (style_out_vsync            ),
//     .vpu_scaler_in_hsync        (style_out_hsync            ),
//     .vpu_scaler_in_de           (style_out_de               ),
//     .vpu_scaler_in_xcnt         (style_out_xcnt             ),
//     .vpu_scaler_in_ycnt         (style_out_ycnt             ),
//     .vpu_scaler_in_rgb          (style_out_rgb              ),

//     .vpu_scaler_in_ready        (),

//     .vpu_scaler_out_vsync       (vpu_scaler_out_vsync       ),
//     .vpu_scaler_out_hsync       (vpu_scaler_out_hsync       ),
//     .vpu_scaler_out_de          (vpu_scaler_out_de          ),
//     .vpu_scaler_out_xcnt        (vpu_scaler_out_xcnt        ),
//     .vpu_scaler_out_ycnt        (vpu_scaler_out_ycnt        ),
//     .vpu_scaler_out_rgb         (vpu_scaler_out_rgb         )
// );

VPU_audio_wave VPU_audio_wave(
    .clk                        (clk                        ),
    .reset                      (reset                      ),

    .vpu_audio_disable          (vpu_audio_disable          ),
    .vpu_audio_mode             (vpu_audio_mode             ),
    .vpu_audio_color_mode       (vpu_audio_color_mode       ),
    .vpu_audio_color_data       (vpu_audio_color_data       ),
    .audio_wave_sx              (vpu_audio_sx               ),
    .audio_wave_sy              (vpu_audio_sy               ),

    .vpu_audio_valid            (vpu_audio_valid            ),
    .vpu_audio_data             (vpu_audio_data             ),

    .audio_wave_in_vsync        (style_out_vsync            ),
    .audio_wave_in_hsync        (style_out_hsync            ),
    .audio_wave_in_de           (style_out_de               ),
    .audio_wave_in_xcnt         (style_out_xcnt             ),
    .audio_wave_in_ycnt         (style_out_ycnt             ),
    .audio_wave_in_rgb          (style_out_rgb              ),

    .audio_wave_out_vsync       (audio_out_vsync            ),
    .audio_wave_out_hsync       (audio_out_hsync            ),
    .audio_wave_out_de          (audio_out_de               ),
    .audio_wave_out_xcnt        (audio_out_xcnt             ),
    .audio_wave_out_ycnt        (audio_out_ycnt             ),
    .audio_wave_out_rgb         (audio_out_rgb              )
);

VPU_OSD #(
    .LOGO_INIT_FILE             ("../sources/osd/osd_logo_128_init.mem"),
    .TXT_INIT_FILE              ("../sources/osd/osd_txt_init.mem")
)VPU_OSD(
    .clk                        (clk                        ),
    .reset                      (reset                      ),

    // .osd_valid_width            (vpu_valid_width            ),
    // .osd_valid_height           (vpu_valid_height           ),
    .osd_valid_width            (13'd640                    ),
    .osd_valid_height           (13'd480                    ),
    .osd_disable                (osd_disable                ),

    .osd_logo_sx                (osd_logo_sx                ),
    .osd_logo_sy                (osd_logo_sy                ),
    
    .osd_txt_sx                 (osd_txt_sx                 ),
    .osd_txt_sy                 (osd_txt_sy                 ),
    .osd_txt_x_area             (osd_txt_x_area             ),
    .osd_txt_speed              (osd_txt_speed              ),
    .osd_color_mode             (osd_color_mode             ),
    .osd_color_set              (osd_color_set              ),

    .osd_txt_disable            (osd_txt_disable            ),
    .osd_txtram_dv              (osd_txtram_dv              ),
    .osd_txtram_data            (osd_txtram_data            ),
    .osd_txtram_addr            (osd_txtram_addr            ),

    // .osd_in_vsync               (audio_out_vsync            ),
    // .osd_in_hsync               (audio_out_hsync            ),
    // .osd_in_de                  (audio_out_de               ),
    // .osd_in_xcnt                (audio_out_xcnt             ),
    // .osd_in_ycnt                (audio_out_ycnt             ),
    // .osd_in_rgb                 (audio_out_rgb              ),
    .osd_in_vsync               (audio_out_vsync            ),
    .osd_in_hsync               (audio_out_hsync            ),
    .osd_in_de                  (audio_out_de               ),
    .osd_in_xcnt                (audio_out_xcnt             ),
    .osd_in_ycnt                (audio_out_ycnt             ),
    .osd_in_rgb                 (audio_out_rgb              ),

    // .osd_out_vsync              (osd_out_vsync              ),
    // .osd_out_hsync              (osd_out_hsync              ),
    // .osd_out_de                 (osd_out_de                 ),
    // .osd_out_xcnt               (osd_out_xcnt               ),
    // .osd_out_ycnt               (osd_out_ycnt               ),
    // .osd_out_rgb                (osd_out_rgb                )
    .osd_out_vsync              (osd_out_vsync              ),
    .osd_out_hsync              (osd_out_hsync              ),
    .osd_out_de                 (osd_out_de                 ),
    .osd_out_xcnt               (osd_out_xcnt               ),
    .osd_out_ycnt               (osd_out_ycnt               ),
    .osd_out_rgb                (osd_out_rgb                )
);

VPU_MENU VPU_MENU(
    .clk                        (clk                        ),
    .reset                      (reset                      ),

    .menu_power                 (menu_power                 ),
    .menu_up                    (menu_up                    ),
    .menu_down                  (menu_down                  ),
    .menu_left                  (menu_left                   ),
    .menu_right                 (menu_right                 ),
    .menu_center                (menu_center                ),

    .cut_to_mode_set            (cut_to_mode_set            ),
    .cut_to_speed_set           (cut_to_speed_set           ),
    .cut_to_disable             (cut_to_disable             ),

    .dis_eff_disable            (dis_eff_disable            ),
    .lumi_set_data              (lumi_set_data              ),
    .contrast_set_data          (contrast_set_data          ),
    .temp_set_data              (temp_set_data              ),
    .tint_set_data              (tint_set_data              ),

    .osd_disable                (osd_disable                ),
    .osd_logo_sx                (osd_logo_sx                ),
    .osd_logo_sy                (osd_logo_sy                ),
    .osd_txt_sx                 (osd_txt_sx                 ),
    .osd_txt_sy                 (osd_txt_sy                 ),
    .osd_txt_x_area             (osd_txt_x_area             ),
    .osd_txt_speed              (osd_txt_speed              ),
    .osd_color_mode             (osd_color_mode             ),

    .style_disable              (style_disable              ),
    .style_mode                 (style_mode                 ),
    .style_bin_th               (style_bin_th               ),
    .style_gamma                (style_gamma                ),

    .vpu_audio_disable          (vpu_audio_disable          ),
    .vpu_audio_mode             (vpu_audio_mode             ),
    .vpu_audio_color_mode       (vpu_audio_color_mode       ),
    .vpu_audio_sx               (vpu_audio_sx               ),
    .vpu_audio_sy               (vpu_audio_sy               ),

    .menu_in_vsync              (osd_out_vsync              ),
    .menu_in_hsync              (osd_out_hsync              ),
    .menu_in_de                 (osd_out_de                 ),
    .menu_in_xcnt               (osd_out_xcnt               ),
    .menu_in_ycnt               (osd_out_ycnt               ),
    .menu_in_rgb                (osd_out_rgb                ),

    .menu_out_vsync             (vpu_out_vsync              ),
    .menu_out_hsync             (vpu_out_hsync              ),
    .menu_out_de                (vpu_out_de                 ),
    .menu_out_xcnt              (vpu_out_xcnt               ),
    .menu_out_ycnt              (vpu_out_ycnt               ),
    .menu_out_rgb               (vpu_out_rgb                )
);


endmodule
