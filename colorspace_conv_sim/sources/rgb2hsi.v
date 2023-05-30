// RGB565转RGB888，再经过两次最小值滤波获取暗通道图像

module rgb2hsi
#(
    parameter               H_DISP = 640        ,   //  图像宽度
    parameter               V_DISP = 480            //  图像高度
)       
(       
    input   wire            clk                 ,   //  时钟
    input   wire            rst_n               ,   //  复位
    //input         
    input   wire            RGB_hsync           ,   //  RGB行同步
    input   wire            RGB_vsync           ,   //  RGB场同步
    input   wire    [23:0]  RGB_data            ,   //  RGB数据
    input   wire            RGB_de              ,   //  RGB数据使能
    //output        
    output  wire            HSI_hsync           ,   //  HSI行同步
    output  wire            HSI_vsync           ,   //  HSI场同步
    output  wire    [7:0]   H_data              ,   //  H数据
    output  wire    [7:0]   S_data              ,   //  S数据
    output  wire    [7:0]   I_data              ,   //  I数据
    output  wire            HSI_de                  //  HSI数据使能
);

    wire    [7:0]           RGB888_R            ;
    wire    [7:0]           RGB888_G            ;
    wire    [7:0]           RGB888_B            ;

    reg     [8:0]           RGB888_R_r         ;
    reg     [8:0]           RGB888_G_r         ;
    reg     [8:0]           RGB888_B_r         ;
//    reg     [7:0]           RGB888_R_r1         ;
//    reg     [7:0]           RGB888_G_r1         ;
//    reg     [7:0]           RGB888_B_r1         ;

    reg     [9:0]           rgb_sum             ;
    reg     [9:0]           rgb_sum_r             ;

    reg     [1:0]           H_flag              ;
//    reg     [1:0]           H_flag_r              ;

    reg     [9:0]           H                   ;
    reg     [9:0]           S                   ;
    reg     [9:0]           I                   ;

    reg     [2:0]           RGB_de_r            ;
    reg     [2:0]           RGB_hsync_r         ;
    reg     [2:0]           RGB_vsync_r         ;

    reg     [9:0]           numerator_H         ;      //  H计算式的分子
    reg     [9:0]           numerator_S         ;      //  S计算式的分子
    reg     [9:0]           denominator_H       ;    //  H计算式的分母

/*******************************************************/
//  clk1 编码，求和
//  获取每个像素的R、G、B三个通道的最小值，耗费1clk
assign  RGB888_R = {RGB_data[23:16]}            ; 
assign  RGB888_G = {RGB_data[15:8]}             ;
assign  RGB888_B = {RGB_data[7:0]}              ;

//  对Hflag编码
always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n) 
        H_flag <= 2'b00;
    else if (RGB888_R <= RGB888_G && RGB888_R <= RGB888_B) 
        H_flag <= 2'b00;  //  R最小
    else if (RGB888_G <= RGB888_R && RGB888_G <= RGB888_B) 
        H_flag <= 2'b01;  //  G最小
    else 
        H_flag <= 2'b10;  //  B最小
    
//    if (RGB888_R == RGB888_G && RGB888_G == RGB888_B)  //  R=G=B
//        H_flag <= 2'b00;
//    else if (RGB888_R == RGB888_G && RGB888_G < RGB888_B)  //  R=G且最小
//        H_flag <= 2'b00;
//    else if (RGB888_R == RGB888_B && RGB888_B < RGB888_G)  //  R=B且最小
//        H_flag <= 2'b01;
//    else if (RGB888_G == RGB888_B && RGB888_B < RGB888_R)  //  G=B且最小
//        H_flag <= 2'b10;
end

//  求三个通道值的和
always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) 
        rgb_sum <= 10'd0;
    else if(RGB_de == 1'b1)//////////////注意要改的
        rgb_sum <= RGB888_R + RGB888_G + RGB888_B;
    else 
        rgb_sum <= 10'd0;
end 

//  数据同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        RGB888_R_r <= 9'd0 ;
        RGB888_G_r <= 9'd0 ;
        RGB888_B_r <= 9'd0 ;
//        rgb_sum_r   <= 10'd0;
//        H_flag_r    <= 2'b00;
    end
    else begin
        RGB888_R_r <= {1'b0,RGB888_R};
        RGB888_G_r <= {1'b0,RGB888_G};
        RGB888_B_r <= {1'b0,RGB888_B};
//        rgb_sum_r   <= rgb_sum;
//        H_flag_r    <= H_flag;
    end
end
/*******************************************************/

/*******************************************************/
//  计算S_SC算法中H、S计算式中的分子和分母
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        begin
            numerator_H   <= 10'd0;
            denominator_H <= 10'd1;       
            numerator_S   <= 10'd0;    
        end
    else if(RGB_de_r[0])
        case(H_flag)
            2'b00:  // 各分量均扩大256倍
            begin
                numerator_H   <= (RGB888_G_r << 1) - RGB888_B_r - RGB888_R_r;
                denominator_H <= RGB888_G_r + RGB888_B_r - (RGB888_R_r << 1);
                numerator_S   <= RGB888_G_r + RGB888_B_r - (RGB888_R_r << 1);
            end    
            2'b01:
            begin
                numerator_H   <= (RGB888_B_r << 1) - RGB888_G_r - RGB888_R_r;
                denominator_H <= RGB888_R_r + RGB888_B_r - (RGB888_G_r << 1);
                numerator_S   <= RGB888_R_r + RGB888_B_r - (RGB888_G_r << 1);
            end 
            2'b10:
            begin
                numerator_H   <= (RGB888_R_r << 1) - RGB888_B_r - RGB888_G_r;
                denominator_H <= RGB888_G_r + RGB888_R_r - (RGB888_B_r << 1);
                numerator_S   <= RGB888_G_r + RGB888_R_r - (RGB888_B_r << 1);
            end                                                   
            default:
            begin
                numerator_H   <= 10'd0;
                denominator_H <= 10'd1;       
                numerator_S   <= 10'd0;                     
            end
        endcase
    else
        numerator_H   <= 10'd0;
        denominator_H <= 10'd1;       
        numerator_S   <= 10'd0;    
end

//  数据同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
//        RGB888_R_r1 <= 8'd0 ;
//        RGB888_G_r1 <= 8'd0 ;
//        RGB888_B_r1 <= 8'd0 ;
        rgb_sum_r   <= 10'd0;
//        H_flag_r    <= 2'b00;
    end
    else begin
//        RGB888_R_r1 <= RGB888_R_r;
//        RGB888_G_r1 <= RGB888_G_r;
//        RGB888_B_r1 <= RGB888_B_r;
        rgb_sum_r   <= rgb_sum;
//        H_flag_r    <= H_flag;
    end
end
/*******************************************************/

/*******************************************************/
//  clk3 
//  由S_SC算法计算H、S、I
//  (1356/4096)×(R+G+B) ≈ 0.33×(R+G+B)
//  I= (1/16)*rgb_sum + (1/16)*rgb_sum + (1/16)*rgb_sum + (1/16)*rgb_sum + (1/16)*rgb_sum + (1/32)*rgb_sum
//  I= (11/32)*rgb_sum
//  I= 0.34375*rgb_sum  
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        begin
//            H <= 8'd0;
//            S <= 8'd0;
//        end
//    else if(RGB_de_r[0])
//        case(H_flag)
//            2'b00:  // 各分量均扩大256倍
//            begin
////                H <= (((RGB888_G_r << 1) - RGB888_B_r - RGB888_R_r) << 8) / (RGB888_G_r + RGB888_B_r - (RGB888_R_r << 1));
//                H <= (((RGB888_G_r << 1) - RGB888_B_r - RGB888_R_r)) / (RGB888_G_r + RGB888_B_r - (RGB888_R_r << 1));
////                S <= ((RGB888_G_r + RGB888_B_r - 2*RGB888_R_r) << 8) / rgb_sum;
//                S <= ((RGB888_G_r + RGB888_B_r - 2*RGB888_R_r)) / rgb_sum;
//            end    
//            2'b01:
//            begin
////                H <= (((RGB888_B_r << 1) - RGB888_G_r -   RGB888_R_r) << 8) / (RGB888_R_r + RGB888_B_r - (RGB888_G_r << 1));
//                H <= (((RGB888_B_r << 1) - RGB888_G_r -   RGB888_R_r)) / (RGB888_R_r + RGB888_B_r - (RGB888_G_r << 1));
////                S <= ((RGB888_R_r + RGB888_B_r - 2*RGB888_G_r) << 8) / rgb_sum;
//                S <= ((RGB888_R_r + RGB888_B_r - 2*RGB888_G_r)) / rgb_sum;
//            end 
//            2'b10:
//            begin
////                H <= (((RGB888_R_r << 1) - RGB888_B_r -   RGB888_G_r) << 8) / (RGB888_G_r + RGB888_R_r - (RGB888_B_r << 1));
//                H <= (((RGB888_R_r << 1) - RGB888_B_r -   RGB888_G_r)) / (RGB888_G_r + RGB888_R_r - (RGB888_B_r << 1));
////                S <= ((RGB888_G_r + RGB888_R_r - 2*RGB888_B_r) << 8) / rgb_sum;
//                S <= ((RGB888_G_r + RGB888_R_r - 2*RGB888_B_r)) / rgb_sum;
//            end                                                   
//            default:
//            begin
//                H <= 8'b0;
//                S <= 8'b0;              
//            end
//        endcase
//    else
//        H <= 8'b0;
//        S <= 8'b0;  
//end

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) 
        H <= 10'd0;
    else if(RGB_de_r[2])////////// 注意修改！！！！！！！！
        if(denominator_H != 10'd0)
            H <= numerator_H / denominator_H;
        else
            H <= numerator_H;
    else 
        H <= 10'd0;
end 

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) 
        S <= 10'd0;
    else if(RGB_de_r[2])////////// 注意修改！！！！！！！！
        if(rgb_sum_r != 10'd0)
            S <= numerator_S / rgb_sum_r;
        else
            S <= numerator_H;
    else 
        S <= 10'd0;
end 

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) 
        I <= 10'd0;
    else if(RGB_de_r[2])
//        I <= (rgb_sum[7:4] + rgb_sum[7:4] + rgb_sum[7:4] + rgb_sum[7:4] + rgb_sum[7:4] + rgb_sum[7:5]);
        I <= (rgb_sum_r[9:4] + rgb_sum_r[9:4] + rgb_sum_r[9:4] + rgb_sum_r[9:4] + rgb_sum_r[9:4] + rgb_sum_r[9:5]);
    else 
        I <= 10'd0;
end 
/*******************************************************/

/*******************************************************/
//  信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        RGB_de_r    <= 3'b0;
        RGB_hsync_r <= 3'b0;
        RGB_vsync_r <= 3'b0;
    end
    else begin
        RGB_de_r    <= {RGB_de_r   [1:0],    RGB_de};
        RGB_hsync_r <= {RGB_hsync_r[1:0], RGB_hsync};
        RGB_vsync_r <= {RGB_vsync_r[1:0], RGB_vsync};
    end
end

assign HSI_hsync = RGB_hsync_r[2]   ;
assign HSI_vsync = RGB_vsync_r[2]   ; 
assign H_data    = H[7:0]           ;
assign S_data    = S[7:0]           ;
assign I_data    = I[7:0]           ;
assign HSI_de    = RGB_de_r   [2]   ;
/*******************************************************/

endmodule