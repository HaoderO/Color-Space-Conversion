module rgb2hsv
(
	input	wire	     	clk				,
	input	wire	     	rst_n			,	
    input   wire            RGB_hsync		,   //RGB行同步
    input   wire            RGB_vsync		,   //RGB场同步
    input   wire    [23:0]  RGB_data		,   //RGB数据
    input   wire            RGB_de			,   //RGB数据使能

    output  wire            HSV_hsync		,   //HSV行同步
    output  wire            HSV_vsync		,   //HSV场同步
    output  wire    [23:0]  HSV_data		,   //HSV数据
    output  wire            HSV_de              //HSV数据使能	
);

	reg     [ 2:0]          RGB_hsync_r		;
	reg     [ 2:0]          RGB_vsync_r		;
	reg     [ 2:0]          RGB_de_r   		;

	wire	[7:0]			rgb_r			;
	wire	[7:0]			rgb_g			;
	wire	[7:0]			rgb_b			;
	
	reg		[7:0] 			top				;//分子
	reg		[13:0] 			top_60			;//*60
	reg		[2:0] 			rgb_se			;
	reg		[2:0] 			rgb_se_n		;//方向
	reg		[7:0] 			max				;//最大分量
	reg		[7:0] 			min				;//最小分量
	reg		[7:0] 			max_min			;//max - min
	reg		[7:0] 			hsv_s_m			;
	reg		[7:0] 			max_n			;
	reg		[7:0] 			division		;//除法
	
	reg		[8:0] 			hsv_h			;// 0 - 360
	reg		[7:0] 			hsv_s			;// 0- 255
	reg		[7:0] 			hsv_v			;// 0- 255

assign rgb_r = RGB_data[23:16]	; 
assign rgb_g = RGB_data[15:8]	; 
assign rgb_b = RGB_data[7:0]	; 

//find max min 1----
assign r_g = (rgb_r > rgb_g)? 1'b1:1'b0; 
assign r_b = (rgb_r > rgb_b)? 1'b1:1'b0; 
assign g_b = (rgb_g > rgb_b)? 1'b1:1'b0; 

// clk1
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		max <= 8'd0;
		min <= 8'd0;
		top <= 8'd0;
		rgb_se <= 3'b010;
	end
	else 
	begin
	case ({r_g,r_b,g_b})
	
	3'b000:
			begin//b g r
			max <= rgb_b;
			min <= rgb_r;
			top <= rgb_g - rgb_r;//-
			rgb_se <= 3'b000;
			end
	3'b001:
			begin//g b r
			max <= rgb_g;
			min <= rgb_r;
			top <= rgb_b - rgb_r;//+
			rgb_se <= 3'b001;
			end
	3'b011:
			begin//g r b
			max <= rgb_g;
			min <= rgb_b;
			top <= rgb_r - rgb_b;//-
			rgb_se <= 3'b011;
			end
	3'b100:
			begin//b r g
			max <= rgb_b;
			min <= rgb_g;
			top <= rgb_r - rgb_g;//+
			rgb_se <= 3'b100;
			end
	3'b110:
			begin//r b g
			max <= rgb_r;
			min <= rgb_g;
			top <= rgb_b - rgb_g;//+
			rgb_se <= 3'b110;
			end
	3'b111:
			begin//r g b
			max <= rgb_r;
			min <= rgb_b;
			top <= rgb_g - rgb_b;//-
			rgb_se <= 3'b111;
			end
	default
			begin
			max <= 8'd0;
			min <= 8'd0;
			top <= 8'd0;
			rgb_se <= 3'b010;
			end
	endcase
end
end

// *60   max - min          2-----------------
// clk2
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		begin
		top_60 <= 14'd0;
		rgb_se_n <= 3'b010;
		max_min <= 8'd0;
		max_n <= 8'd0;
		end
	else
		begin
		top_60 <= {top,6'b000000} - {top,2'b00};//60 = 2^6 - 2^2
		rgb_se_n <= rgb_se;
		max_min <= max - min;
		max_n <= max;
		end
end
//   /(max - min)    3----------------------
always @ (*)
begin
	division = (max_min > 8'd0) ? top_60 / max_min : 8'd240;//注意max = min  
end

// clk3
// + - 120 240 360
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	
		hsv_h <= 9'd0;
	
	else 
	begin
	case (rgb_se_n)
	
	3'b000:
			//b g r
			hsv_h <= 9'd240 - division;//-
			
	3'b001:
			//g b r
			hsv_h <= 9'd120 + division;//+
			
	3'b011:
			//g r b
			hsv_h <= 9'd120 - division;//-
			
	3'b100:
			//b r g
			hsv_h <= 9'd240 + division;//+
			
	3'b110:
			//r b g
			hsv_h <= 9'd360 - division;//-
			
			
	3'b111:
			//r g b
			hsv_h <= division;//+
			
	default
			hsv_h <= 9'd0;
	endcase
end
end

//  s=(max - min)/max * 256
always @ (*)
begin
	hsv_s_m = (max_n > 8'd0)? {max_min[7:0],8'b00000000} / max_n : 8'd0;
end

always@(posedge clk or negedge rst_n)
begin
	if (!rst_n)
      hsv_s <= 8'd0;
	else
	hsv_s <= hsv_s_m;
end
//  hsv_v = max
always@(posedge clk or negedge rst_n)
begin
  if (!rst_n)
  hsv_v <= 8'd0;
  else
  hsv_v <= max_n;
 end
 // 3-------------------

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

assign HSV_hsync = RGB_hsync_r[2];
assign HSV_vsync = RGB_vsync_r[2];
assign HSV_de    = RGB_de_r[2];
assign HSV_data = {hsv_h[8:1],hsv_s,hsv_v}; 

endmodule