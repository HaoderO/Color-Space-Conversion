quit -sim

.main clear

vlib work

vmap work work

vlog ./../../sources/*.v
vlog ./../*.v

vsim -voptargs=+acc work.top_tb
#vsim -novopt work.top_tb

#add wave -divider {rgb2hsi}
#add wave /top_tb/u_top/u_rgb2hsi/*

#add wave -divider {rgb2hsv}
#add wave /top_tb/u_top/u_rgb2hsv/*

#add wave -divider {rgb2ycbcr}
#add wave /top_tb/u_top/u_rgb2ycbcr/*

add wave -divider {top}
add wave /top_tb/u_top/*

run -all