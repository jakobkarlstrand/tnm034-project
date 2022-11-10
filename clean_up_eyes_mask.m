function [outmask] = clean_up_eyes_mask(mask,regions)

MIN_ANGLE = 50;
MIN_AREA = 70;
img_size = size(mask);
img_y = img_size(1);
for k = 1 : length(regions)
  circularity = regions(k).Circularity();
  area = regions(k).Area();
  orientation = regions(k).Orientation();
    
  centerY = regions(k).Centroid(2);
  
  
  if ( area < MIN_AREA || circularity < 0.40 || (orientation > MIN_ANGLE || orientation < -MIN_ANGLE) || centerY > 3/5*img_y) % 
    bound = regions(k).BoundingBox();
    
    bx = int64(bound(1)); % Pos X
    by = int64(bound(2)); % Pos Y
    bw = int64(bound(3)); % Width X
    bh = int64(bound(4)); % Height Y
    mask(by:by+bh,bx:bx+bw) = 0;
      
    
  end

end

% figure
% imshow(mask)
% title("ahdoihaiw")


regions = regionprops(mask, 'Centroid', 'BoundingBox');
if length(regions) > 2
    min_k = 9999;
    best_match1 = [0 0];
    best_match2 = [0 0];

    for i = 1:length(regions) -1

        for j = i+1 : length(regions)
            xy1 = regions(i).Centroid();
            xy2 = regions(j).Centroid();
            x1 = xy1(1);
            x2 = xy2(1);
            y1 = xy1(2);
            y2 = xy2(2);
            if y2-y1 == 0
                % Do nothing
                
            else
                k_angle =   (x2-x1) / (y2-y1);
                if k_angle < min_k

                    min_k = k_angle;
                    best_match1 = [x1 y1];
                    best_match2 = [x2 y2];
                end

            end

           

        end
    end
for i = 1:length(regions)
    xy = regions(i).Centroid();
    if (xy(1) == best_match1(1) && xy(2) == best_match1(2)) || (xy(1) == best_match2(1) && xy(2) == best_match2(2))
    
    
    else

        bound = regions(i).BoundingBox();
    
    bx = int64(bound(1)); % Pos X
    by = int64(bound(2)); % Pos Y
    bw = int64(bound(3)); % Width X
    bh = int64(bound(4)); % Height Y
    mask(by:by+bh,bx:bx+bw) = 0;

    end


end

end
% figure
% imshow(mask)
% hold on
% plot(best_match1(1), best_match1(2), 'b+', 'MarkerSize', 10, 'LineWidth', 3);
% plot(best_match2(1), best_match2(2), 'b+', 'MarkerSize', 10, 'LineWidth', 3);

outmask = mask; % Return modified mask
 
end

