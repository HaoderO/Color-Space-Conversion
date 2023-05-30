module rgb2ycbcr
(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    input   wire            RGB_hsync           ,   //RGB行同步
    input   wire            RGB_vsync           ,   //RGB场同步
    input   wire    [23:0]  RGB_data            ,   //RGB数据
    input   wire            RGB_de              ,   //RGB数据使能

    output  wire            YCbCr_hsync         ,   //YCbCr行同步
    output  wire            YCbCr_vsync         ,   //YCbCr场同步
    output  wire    [23:0]  YCbCr_data          ,   //YCbCr数据
    output  wire            YCbCr_de                //YCbCr数据使能
);

    wire    [ 7:0]          R0, G0, B0          ;
    reg     [15:0]          R1, G1, B1          ;
    reg     [15:0]          R2, G2, B2          ;
    reg     [15:0]          R3, G3, B3          ;
    reg     [15:0]          Y1, Cb1, Cr1        ;
    reg     [ 7:0]          Y2, Cb2, Cr2        ;
    
    reg     [ 2:0]          RGB_hsync_r         ;
    reg     [ 2:0]          RGB_vsync_r         ;
    reg     [ 2:0]          RGB_de_r            ;

assign R0 = RGB_data[23:16];
assign G0 = RGB_data[15: 8];
assign B0 = RGB_data[ 7: 0];

//  clk1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        {R1,G1,B1} <= {16'd0, 16'd0, 16'd0};
        {R2,G2,B2} <= {16'd0, 16'd0, 16'd0};
        {R3,G3,B3} <= {16'd0, 16'd0, 16'd0};
    end
    else begin
        {R1,G1,B1} <= { {R0 * 16'd77},  {G0 * 16'd150}, {B0 * 16'd29 } };
        {R2,G2,B2} <= { {R0 * 16'd43},  {G0 * 16'd85},  {B0 * 16'd128} };
        {R3,G3,B3} <= { {R0 * 16'd128}, {G0 * 16'd107}, {B0 * 16'd21 } };
    end
end

//  clk2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        Y1  <= 16'd0;
        Cb1 <= 16'd0;
        Cr1 <= 16'd0;
    end
    else begin
        Y1  <= R1 + G1 + B1;
        Cb1 <= B2 - R2 - G2 + 16'd32768; //128扩大256倍
        Cr1 <= R3 - G3 - B3 + 16'd32768; //128扩大256倍
    end
end

//  clk3
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        Y2  <= 8'd0;
        Cb2 <= 8'd0;
        Cr2 <= 8'd0;
    end
    else begin
        Y2  <= Y1[15:8];  
        Cb2 <= Cb1[15:8];
        Cr2 <= Cr1[15:8];
    end
end

assign Y_data = {Y2[7:0],Y2[7:0],Y2[7:0]}; //只取Y分量输出

//  信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        RGB_hsync_r <= 3'b0;
        RGB_vsync_r <= 3'b0;
        RGB_de_r    <= 3'b0;
    end
    else begin  
        RGB_hsync_r <= {RGB_hsync_r[1:0], RGB_hsync};
        RGB_vsync_r <= {RGB_vsync_r[1:0], RGB_vsync};
        RGB_de_r    <= {RGB_de_r[1:0],    RGB_de};
    end
end

assign YCbCr_hsync = RGB_hsync_r[2];
assign YCbCr_vsync = RGB_vsync_r[2];
assign YCbCr_de    = RGB_de_r[2];
assign YCbCr_data  = {Y2,Cb2,Cr2};

endmodule