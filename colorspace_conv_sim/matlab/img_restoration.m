clear all;
close all;
clc;

origin_img = imread('lena.jpg');
[v,h,N] = size(origin_img);
processed_img = uint8(zeros(v,h,N));

fid = fopen('HSI.txt','r');
for i = 1:v
    for j = 1:h
        value = fscanf(fid,'%s',1);
        processed_img(i,j,1) = uint8(hex2dec(value(1:2)));
        processed_img(i,j,2) = uint8(hex2dec(value(3:4)));
        processed_img(i,j,3) = uint8(hex2dec(value(5:6)));  
    end 
end
fclose(fid);                                    

subplot(121);imshow(origin_img), title('origin');
subplot(122);imshow(processed_img),title('processed');

imwrite(processed_img,'processed_img.jpg');