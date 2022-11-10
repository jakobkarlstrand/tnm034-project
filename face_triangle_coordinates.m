function [xy1,xy2,xy3] = face_triangle_coordinates(mouth_mask,eye_mask)
%Given the mouth and eye mask. Returns the three x and y coordinates for
%the face triangle from mouth to eyes

% Get centers of all blobs / shapes in the image
% Ideally 1 for mouth and 2 for eyes
mouth_regions = regionprops(mouth_mask, 'Centroid','Orientation', 'BoundingBox');
eyes_regions = regionprops(eye_mask, 'Centroid', 'Circularity', 'BoundingBox', 'Orientation', 'Area');


if length(mouth_regions) > 1
    mouth_mask = clean_up_mouth_mask(mouth_mask, mouth_regions);
    mouth_regions = regionprops(mouth_mask, 'Centroid');
  
end

if length(eyes_regions) > 2
    eye_mask = clean_up_eyes_mask(eye_mask, eyes_regions);
    eyes_regions = regionprops(eye_mask, 'Centroid');
end










xy1 = [eyes_regions(1).Centroid(1),eyes_regions(1).Centroid(2)];
xy2 = [eyes_regions(2).Centroid(1),eyes_regions(2).Centroid(2)];
xy3 = [mouth_regions(1).Centroid(1), mouth_regions(1).Centroid(2)];



%face_mask = eye_mask + mouth_mask;


end