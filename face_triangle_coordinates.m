function [xy1,xy2,xy3] = face_triangle_coordinates(mouth_mask,eye_mask)
%Given the mouth and eye mask. Returns the three x and y coordinates for
%the face triangle from mouth to eyes

% Get centers of all blobs / shapes in the image
% Ideally 1 for mouth and 2 for eyes
mouth_blobMeasurements = regionprops(mouth_mask, 'Centroid','Orientation', 'BoundingBox');
eyes_blobMeasurements = regionprops(eye_mask, 'Centroid', 'Circularity');


if length(mouth_blobMeasurements) > 1
    mouth_mask = clean_up_mouth_mask(mouth_mask, mouth_blobMeasurements);
    mouth_regions = regionprops(mouth_mask, 'Centroid','Orientation', 'BoundingBox');
end

figure
imshow(mouth_mask);

hold on


for k = 1 : length(mouth_regions)
  x = mouth_regions(k).Centroid(1);
  y = mouth_regions(k).Centroid(2);
  plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 3);

end
hold off
figure
imshow(eye_mask, []);
hold on

if length(eyes_blobMeasurements) > 2
    
end


for k = 1 : length(eyes_blobMeasurements)
  x = eyes_blobMeasurements(k).Centroid(1);
  y = eyes_blobMeasurements(k).Centroid(2);
  plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 3);

end
end