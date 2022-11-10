function [outmask] = clean_up_mouth_mask(mask,regions, lEye, rEye)

MAX_ANGLE = 12;
img_size = size(mask);
img_y = img_size(1);



for k = 1 : length(regions)
  
    mouthY = regions(k).Centroid(2);

    if mouthY > 3/5*img_y && mouthY <= 3.9/5*img_y
       

    else
    bound = regions(k).BoundingBox();
    
    bx = int64(bound(1)); % Pos X
    by = int64(bound(2)); % Pos Y
    bw = int64(bound(3)); % Width X
    bh = int64(bound(4)); % Height Y
    

    mask(by:by+bh,bx:bx+bw) = 0;
    end
  
end
regions = regionprops(mask, 'Centroid', 'BoundingBox');
min_dist = [length(regions)];
for k = 1 : length(regions)
  mouthX = regions(k).Centroid(1);
  mouthY = regions(k).Centroid(2);

  dst_left_eye = sqrt( (mouthX-lEye(1)) *(mouthX-lEye(1)) + (mouthY-lEye(2))*(mouthY-lEye(2)));
  dst_right_eye = sqrt((mouthX-rEye(1)) *(mouthX-rEye(1)) + (mouthY-rEye(2))*(mouthY-lEye(2)));
  difference = abs(dst_right_eye-dst_left_eye);
  
  min_dist(k) = difference;

end

[val, idx] = min(min_dist);

for k = 1 : length(regions)

    if k == idx

    else
    bound = regions(k).BoundingBox();
    
    bx = int64(bound(1)); % Pos X
    by = int64(bound(2)); % Pos Y
    bw = int64(bound(3)); % Width X
    bh = int64(bound(4)); % Height Y
    

    mask(by:by+bh,bx:bx+bw) = 0;
    end
  
end







outmask = mask; % Return modified mask
 
end

