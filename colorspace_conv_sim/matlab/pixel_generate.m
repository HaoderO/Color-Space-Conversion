clear all;
close all;
clc;

origin_img = imread('lena.jpg');
[v,h,N] = size(origin_img);  
RGB_ij = uint64(zeros(v,h)); 

fid = fopen('origin_img.txt','w');
for i = 1:v
    for j = 1:h
        R = double(origin_img(i,j,1));
        G = double(origin_img(i,j,2));
        B = double(origin_img(i,j,3));
        RGB          = R*(2^16) + G*(2^8) + B;
        RGB_ij(i,j)  = RGB;
        RGB_hex      = dec2hex(RGB);
        fprintf(fid,'%s\n',RGB_hex);
    end
end
fclose(fid);