%%This function uses the edge density based method to detect eyes.
%%It takes an images, gray scales it, uses an sobel edge detector and then
%%performs morphological operations.
function [edgeImage] = eye_detection_edge_based(currentImage)
grayImage = rgb2gray(currentImage);
sobelImage = edge(grayImage, 'sobel');
    
% Morphological operations, dilated twice, erosion three times.
SE = strel('disk', 4);  
edgeImage = imdilate(sobelImage, SE);
edgeImage = imdilate(edgeImage, SE);
edgeImage = imerode(edgeImage, SE);
edgeImage = imerode(edgeImage, SE);
edgeImage = imerode(edgeImage, SE);
end