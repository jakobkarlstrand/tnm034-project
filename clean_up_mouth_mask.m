function [outmask] = clean_up_mouth_mask(mask,regions)

MAX_ANGLE = 12;
% figure
% imshow(mask)
% hold on
for k = 1 : length(regions)
  alpha = regions(k).Orientation();
  if alpha > MAX_ANGLE || alpha < -MAX_ANGLE % If orientation is not horizontal
   
    bound = regions(k).BoundingBox();
    
    bx = int64(bound(1)); % Pos X
    by = int64(bound(2)); % Pos Y
    bw = int64(bound(3)); % Width X
    bh = int64(bound(4)); % Height Y
    
%     rectangle('Position', [bx, by, bw, bh],...
%   'EdgeColor','r', 'LineWidth', 3)
%     plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 3);

    mask(by:by+bh,bx:bx+bw) = 0;
  end

end
% hold off
% disp("bw: " + bw)
%     disp("bh: " + bh)

outmask = mask; % Return modified mask
 
end

