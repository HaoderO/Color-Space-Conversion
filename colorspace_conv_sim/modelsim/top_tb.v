`timescale 1ns/1ns          //  时间精度
`define    clock_period 20  //  时钟周期

module top_tb;
parameter           H_DISP = 400        ;   //  图像宽度
parameter           V_DISP = 306        ;   //  图像高度

reg                 clk                 ;
reg                 rst_n               ;

wire                VGA_hsync           ;   //  VGA行同步
wire                VGA_vsync           ;   //  VGA场同步
wire                VGA_de              ;   //  VGA数据使能

wire    [ 7:0]      H_data              ;
wire    [ 7:0]      S_data              ;
wire    [ 7:0]      I_data              ;
wire    [23:0]      HSI_data            ;

top
#(
    .H_DISP         (H_DISP             ),  //  图像宽度
    .V_DISP         (V_DISP             )   //  图像高度
)   
u_top   
(                                         
    .clk            (clk                ), 
    .rst_n          (rst_n              ), 
        
    .VGA_hsync      (VGA_hsync          ),  //  VGA行同步
    .VGA_vsync      (VGA_vsync          ),  //  VGA场同步
    //.H_data         (H_data             ),  //  VGA数据
    //.S_data         (S_data             ),  //  VGA数据
    //.I_data         (I_data             ),  //  VGA数据
    .VGA_data         (HSI_data             ),  //  VGA数据
    .VGA_de         (VGA_de             )   //  VGA数据使能
);

//assign HSI_data = {H_data , S_data , I_data};

initial begin
    clk = 1;
    forever
        #(`clock_period/2) clk = ~clk;
end

initial begin
    rst_n = 0; #(`clock_period*20+1);
    rst_n = 1;
end

//  新建txt文件用以存储modelsim仿真数据
//integer HSI_H_txt;
//integer HSI_S_txt;
//integer HSI_I_txt;
integer HSI_txt  ;

initial 
begin
//    HSI_H_txt = $fopen("./../../matlab/HSI_H.txt");
//    HSI_S_txt = $fopen("./../../matlab/HSI_S.txt");
//    HSI_I_txt = $fopen("./../../matlab/HSI_I.txt");
    HSI_txt   = $fopen("./../../matlab/HSI.txt"  );
end

//  将仿真数据写入txt
reg [20:0] pixel_cnt;

always @(posedge clk) begin
    if(!rst_n) begin
        pixel_cnt <= 0;
    end
    else if(VGA_de) 
    begin
        pixel_cnt = pixel_cnt + 1;
//        $fdisplay(HSI_H_txt,"%h",H_data  );
//        $fdisplay(HSI_S_txt,"%h",S_data  );
//        $fdisplay(HSI_I_txt,"%h",I_data  );
        $fdisplay(HSI_txt  ,"%h",HSI_data);
        if(pixel_cnt == H_DISP*V_DISP)
            $stop;
    end
end

endmodule