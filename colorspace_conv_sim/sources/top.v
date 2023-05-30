`timescale 1 ns/1 ns

module top
#(
    parameter               H_DISP = 640        ,   //  图像宽度
    parameter               V_DISP = 480            //  图像高度
)  
(  
    input   wire            clk                 ,   //  时钟
    input   wire            rst_n               ,   //  复位
  
    output  wire            VGA_hsync           ,   //  行同步
    output  wire            VGA_vsync           ,   //  场同步
    //output  wire    [7:0]   H_data              ,   //  数据
    //output  wire    [7:0]   S_data              ,   //  数据
    //output  wire    [7:0]   I_data              ,   //  数据
    output  wire    [23:0]  VGA_data            ,   //  RGB数据
    output  wire            VGA_de                  //  数据使能
);  
  
    wire                    RGB_hsync           ;   //  RGB行同步
    wire                    RGB_vsync           ;   //  RGB场同步
    wire    [23:0]          RGB_data            ;   //  RGB数据
    wire                    RGB_de              ;   //  RGB数据使能

img_gen
#(
    .H_DISP                 (H_DISP             ),  //  图像宽度
    .V_DISP                 (V_DISP             )   //  图像高度
)  
u_img_gen  
(  
    .clk                    (clk                ),  //  时钟
    .rst_n                  (rst_n              ),  //  复位
  
    .img_hsync              (RGB_hsync          ),  //  RGB行同步
    .img_vsync              (RGB_vsync          ),  //  RGB场同步
    .img_data               (RGB_data           ),  //  RGB数据，RGB888
    .img_de                 (RGB_de             )   //  RGB数据使能
);

//rgb2hsi
//#(
//    .H_DISP                 (H_DISP             ),   //  图像宽度
//    .V_DISP                 (V_DISP             )    //  图像高度
//)    
//u_rgb2hsi   
//(       
//    .clk                    (clk                ),   //  时钟
//    .rst_n                  (rst_n              ),   //  复位
//    .RGB_hsync              (RGB_hsync          ),   //  RGB行同步
//    .RGB_vsync              (RGB_vsync          ),   //  RGB场同步
//    .RGB_data               (RGB_data           ),   //  RGB数据
//    .RGB_de                 (RGB_de             ),   //  RGB数据使能
//
//    .HSI_hsync              (VGA_hsync          ),   //  HSI行同步
//    .HSI_vsync              (VGA_vsync          ),   //  HSI场同步
//    .H_data                 (H_data             ),   //  H数据
//    .S_data                 (S_data             ),   //  S数据
//    .I_data                 (I_data             ),   //  I数据
//    .HSI_de                 (VGA_de             )    //  HSI数据使能
//);

rgb2hsv u_rgb2hsv
(
	.clk                    (clk            ),
	.rst_n			        (rst_n		    ),	
    .RGB_hsync		        (RGB_hsync	    ),   //RGB行同步
    .RGB_vsync		        (RGB_vsync	    ),   //RGB场同步
    .RGB_data		        (RGB_data	    ),   //RGB数据
    .RGB_de			        (RGB_de		    ),   //RGB数据使能

    .HSV_hsync		        (VGA_hsync  ),   //HSV行同步
    .HSV_vsync		        (VGA_vsync  ),   //HSV场同步
    .HSV_data		        (VGA_data   ),   //HSV数据
    .HSV_de                 (VGA_de     )     //HSV数据使能	
);

//rgb2ycbcr u_rgb2ycbcr
//(
//    .clk                 (clk           ),
//    .rst_n               (rst_n         ),
//    .RGB_hsync           (RGB_hsync     ),   //RGB行同步
//    .RGB_vsync           (RGB_vsync     ),   //RGB场同步
//    .RGB_data            (RGB_data      ),   //RGB数据
//    .RGB_de              (RGB_de        ),   //RGB数据使能
//
//    .YCbCr_hsync         (VGA_hsync     ),   //YCbCr行同步
//    .YCbCr_vsync         (VGA_vsync     ),   //YCbCr场同步
//    .YCbCr_data          (VGA_data      ),   //YCbCr数据
//    .YCbCr_de            (VGA_de        )    //YCbCr数据使能
//);

endmodule