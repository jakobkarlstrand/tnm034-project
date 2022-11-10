%%The function uses three methods for eye detection, illumination-, colour-
%%and edge-based. It then combines the returned images according to the 
% "A hybrid method for eyesdetection in facial images" paper.

function [hybridImage] = eye_detection(currentImage)
[chromaIm, lumaIm, illuImage] = eye_detection_illumination_based(currentImage);
colourImage = eye_detection_colour_based(currentImage);
edgeImage = eye_detection_edge_based(currentImage);

illuImage = eye_rules(illuImage);
colourImage = eye_rules(colourImage);
edgeImage = eye_rules(edgeImage);

%%combinding images.
illColImage = illuImage & colourImage;
colEdgeImage = colourImage & edgeImage;
illEdgeImage = illuImage & edgeImage;
hybridImage = illColImage | colEdgeImage | illEdgeImage; %%Combine the images
end