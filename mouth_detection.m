function [MouthMap] = untitled2(currentImage)
YCbCr = rgb2ycbcr(currentImage); %%convert the first image in our folder to YCbCr.
[Y, Cb, Cr] = imsplit(YCbCr); %%split the image into Y, Cb and Cr.
Cb = mat2gray(Cb) + 1;
Cr = mat2gray(Cr) + 1;
n = 0.95 * mean(Cr(:).^2)./(mean(Cr(:)./Cb(:))); %%n is an estimated ratio between Cr^2 and Cr/Cb.
MouthMap = (Cr.^2).*((Cr.^2) - n * (Cr./Cb)).^2; %%Formula for the mouth map.
MouthMap = (MouthMap- min(MouthMap(:)))/(max(MouthMap(:)) - min(MouthMap(:))); %%Normalize

SE = strel('disk', 6);
Threshold = 0.15;
MouthMap = MouthMap > Threshold;
MouthMap = imopen(MouthMap, SE); %%remove small objects
MouthMap = imclose(MouthMap, SE); %%remove small objects
MouthMap = imdilate(MouthMap, SE); %%Increase size.
end