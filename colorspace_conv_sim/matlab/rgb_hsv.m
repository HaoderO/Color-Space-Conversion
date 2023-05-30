clear all;
close all;
clc;

rgb_image = imread('lena.jpg');

hsv_image = rgb2hsv(rgb_image);

imshow(hsv_image);

subplot(121);imshow(rgb_image), title('lena RGB');
subplot(122);imshow(hsv_image),title('lena HSV');