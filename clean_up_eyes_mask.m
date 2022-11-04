function [outmask] = clean_up_eyes_mask(mask,regions)


for k = 1 : length(regions)
  circularity = regions(k).Circularity();
   alpha = regions(k).Orientation();
  
  
  if circularity < 0.7 || (alpha > 5 || alpha < -5) % 
    bound = regions(k).BoundingBox();
    
    bx = uint8(bound(1)); % Pos X
    by = uint8(bound(2)); % Pos Y
    bw = uint8(bound(3)); % Width X
    bh = uint8(bound(4)); % Height Y
    mask(by:by+bh,bx:bx+bw) = 0;
      
    
  end

end

outmask = mask; % Return modified mask
 
end

