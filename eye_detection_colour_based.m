%%This function uses the colour based method to detect eyes. It converts 
% the image into a histogram equalized grey level image, then a threshold
% is used to extract the eye regions.

function [colourImage] = eye_detection_colour_based(currentImage)
grayImage = rgb2gray(currentImage);
histImage = histeq(grayImage);

Threshold = 20/255; %%20 is a good threshold according to the paper.
                    % Division with 255 due to [0,1].
colourImage = histImage > Threshold;
end