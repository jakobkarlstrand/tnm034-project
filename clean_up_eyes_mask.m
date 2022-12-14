function [outmask] = clean_up_eyes_mask(mask,regions)

MIN_ANGLE = 70;
MIN_AREA = 70;
img_size = size(mask);
img_y = img_size(1);

for k = 1 : length(regions)

  area = regions(k).Area();

    
  centerY = regions(k).Centroid(2);
  
  
   if ( area < MIN_AREA   || centerY > 3/5*img_y) || centerY < 2/5*img_y % 
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





regions = regionprops(mask, 'Centroid', 'BoundingBox', 'Area');
goodMatches = [length(regions);6];
if length(regions) > 2
    min_k = 0.1;
    best_match1 = [0 0];
    best_match2 = [0 0];
    
    idx_matches = 1;


    for i = 1:length(regions) -1

        for j = i+1 : length(regions)
            xy1 = regions(i).Centroid();
            xy2 = regions(j).Centroid();
            x1 = xy1(1);
            x2 = xy2(1);
            y1 = xy1(2);
            y2 = xy2(2);
            if x2-x1 == 0
                % Do nothing
                best_match1 = [x1 y1];
                best_match2 = [x2 y2];
                goodMatches(idx_matches , 1) = x1;
                goodMatches(idx_matches , 2) = y1;
                goodMatches(idx_matches , 3) = x2;
                goodMatches(idx_matches , 4) = y2;
                goodMatches(idx_matches , 5) = regions(i).Area();
                goodMatches(idx_matches , 6) = regions(j).Area();
                idx_matches = idx_matches +1;
              
            else
                k_angle =   abs((y2-y1) / (x2-x1));
                if k_angle < min_k
                    
                    min_k = k_angle;
                    best_match1 = [x1 y1];
                    best_match2 = [x2 y2];
                     goodMatches(idx_matches , 1) = x1;
                    goodMatches(idx_matches , 2) = y1;
                    goodMatches(idx_matches , 3) = x2;
                    goodMatches(idx_matches , 4) = y2;
                    goodMatches(idx_matches , 5) = regions(i).Area();
                goodMatches(idx_matches , 6) = regions(j).Area();
                    idx_matches = idx_matches +1;
                end

            end

           

        end
    end

    closest = 999;
    biggest = 0;

 

for i = 1:idx_matches-1
    x1 = goodMatches(i,1);
    y1 = goodMatches(i,2);
    x2 = goodMatches(i,3);
    y2 = goodMatches(i,4);
    a1 = goodMatches(i,5);
    a2 = goodMatches(i,6);

    center = (2/5*img_y  +3/5*img_y)/2;

    if  abs(center - (y1+y2)/2) < closest
        if a1+a2 > biggest
            best_match1 = [x1,y1];
        best_match2 = [x2,y2];
        closest = 3/5*img_y - (y1+y2)/2;
        biggest = a1+a2;
        end
        
    end
end


for i = 1:length(regions)
    xy = regions(i).Centroid();
    should_delete = true;
    for j = 1:idx_matches-1
    x1 = goodMatches(j,1);
    y1 = goodMatches(j,2);
    x2 = goodMatches(j,3);
    y2 = goodMatches(j,4);

    if xy(1) == x1 && xy(2) == y1 || xy(1) == x2 && xy(2) == y2
    
    should_delete = false;
    else
 
      
    end

    end

    if should_delete

          bound = regions(i).BoundingBox();
    
    bx = int64(bound(1)); % Pos X
    by = int64(bound(2)); % Pos Y
    bw = int64(bound(3)); % Width X
    bh = int64(bound(4)); % Height Y
    mask(by:by+bh,bx:bx+bw) = 0;
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


outmask = mask; % Return modified mask
 
end

