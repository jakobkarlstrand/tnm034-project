%%This function uses the illumination based method to detect eyes.
%%It takes an images and calculates a chroma and luma eye map as well as a
%%combination of the two. 
function [chromaIm, lumaIm, illuImage] = eye_detection_illumination_based(currentImage)
YCbCr = rgb2ycbcr(currentImage); %%convert the first image in our folder to YCbCr.
[Y, Cb, Cr] = imsplit(YCbCr); %%split the image into Y, Cb and Cr.
Y = uint16(255 * mat2gray(Y)); %%normalize to interval [0,255]
Cb = uint16(255 * mat2gray(Cb)); %%normalize to interval [0,255]
Cr = uint16(255 * mat2gray(Cr)); %%normalize to interval [0,255]

EyeMapC = (1/3) *(Cb.^2 + (255 - Cr).^2 + (Cb./Cr)); %%Chroma eye map.
chromaIm = im2double(histeq(EyeMapC)); %%Convert to double

SE = strel('disk', 4); %Strukturelement, can assume different shapes. 
%Erosion (imerode(IM, SE)) = krympning, used for object separation. 
%Dilation (imdilate(IM,SE)) = Expansion, used to fill holes and gaps. 
EyeMapL = imdilate(Y, SE) ./ (imerode(Y, SE) + 1); %%Luma eye map.
lumaIm = im2double(histeq(EyeMapL));

EyeMap = histeq(chromaIm.*lumaIm); %%Create the combined eye map. 
%%The resulting eye map is then dilated, masked and normalized to brighten
%%both the eyes and suppress other facial areas....and then
%%iterative thresholding is used on this eye map.
EyeMap = (EyeMap - min(EyeMap(:))) / (max(EyeMap(:)) - min(EyeMap(:))); %%Normalize
Threshold = 0.85;
EyeMap = EyeMap > Threshold;
illuImage = imdilate(EyeMap, SE);
end