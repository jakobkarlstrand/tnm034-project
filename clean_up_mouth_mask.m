function [outmask] = clean_up_mouth_mask(mask,meassurements)


for k = 1 : length(meassurements)
  alpha = meassurements(k).Orientation();
  
  if alpha > 5 || alpha < -5 % If orientation is not horizontal
    bound = meassurements(k).BoundingBox();
    
    bx = uint8(bound(1)); % Pos X
    by = uint8(bound(2)); % Pos Y
    bw = uint8(bound(3)); % Width X
    bh = uint8(bound(4)); % Height Y
      mask(by:by+bh,bx:bx+bw) = 0;
      
    
  end

end

outmask = mask; % Return modified mask
 
end

