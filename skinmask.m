function [mask_threshold] = skinmask(currentImage, threshold)

YCbCr = rgb2ycbcr(currentImage); %%convert the first image in our folder to YCbCr.
[Y, Cb, Cr] = imsplit(YCbCr); %%split the image into Y, Cb and Cr.'

Cb = Cb*255;
Cr = Cr*255;

mask = zeros(size(currentImage, 1), size(currentImage, 2));
matrix = skinprobabilitymatrix();
imwrite(matrix, "skinprobability.png")
%matrix_blurred = imgaussfilt(matrix,3);
%imwrite(matrix_blurred, "skinprobability_blurred.png")

matrix = matrix./max(matrix(:));


for r = 1:size(mask, 1)    % for number of rows of the image
    for c = 1:size(mask, 2)    % for number of columns of the image
        mask(r,c) = matrix(round(Cb(r,c)), round(Cr(r,c)));
    end
end

figure;

mask_threshold = mask > threshold;

end

