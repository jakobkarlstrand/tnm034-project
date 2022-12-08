function [mask_threshold] = skinmask(currentImage, threshold, matrix)

YCbCr = rgb2ycbcr(currentImage); %%convert the first image in our folder to YCbCr.
[Y, Cb, Cr] = imsplit(YCbCr); %%split the image into Y, Cb and Cr.'

Cb = Cb*255;
Cr = Cr*255;

mask = zeros(size(currentImage, 1), size(currentImage, 2));


%%Multiply currentImage with skin probability matrix
for r = 1:size(mask, 1)    % for number of rows of the image
    for c = 1:size(mask, 2)    % for number of columns of the image
        mask(r,c) = matrix(round(Cb(r,c)), round(Cr(r,c)));
    end
end

mask_binary = mask > threshold;



%Close image
se = strel('diamond',10);
closeIm = imclose(mask_binary,se);


%Fill holes in image
fillIm = imfill(closeIm,"holes");


%Erode 
se = strel('diamond',10);
erodeIm = imerode(fillIm,se);

biggestObject = bwareafilt(fillIm,1);

mask_threshold = biggestObject;



end

