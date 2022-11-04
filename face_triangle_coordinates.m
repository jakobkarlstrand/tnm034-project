function [xy1,xy2,xy3] = face_triangle_coordinates(mouth_mask,eye_mask)
%Given the mouth and eye mask. Returns the three x and y coordinates for
%the face triangle from mouth to eyes

% Get centers of all blobs / shapes in the image
% Ideally 1 for mouth and 2 for eyes
mouth_regions = regionprops(mouth_mask, 'Centroid','Orientation', 'BoundingBox');
eyes_regions = regionprops(eye_mask, 'Centroid', 'Circularity', 'BoundingBox', 'Orientation');


if length(mouth_regions) > 1
    mouth_mask = clean_up_mouth_mask(mouth_mask, mouth_regions);
    mouth_regions = regionprops(mouth_mask, 'Centroid');
    figure
    imshow(mouth_mask)
end

if length(eyes_regions) > 2
    eye_mask = clean_up_eyes_mask(eye_mask, eyes_regions);
    eyes_regions = regionprops(eye_mask, 'Centroid');
end

figure
imshow(mouth_mask,[]);

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



for k = 1 : length(eyes_regions)
  x = eyes_regions(k).Centroid(1);
  y = eyes_regions(k).Centroid(2);
  plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 3);

end
end