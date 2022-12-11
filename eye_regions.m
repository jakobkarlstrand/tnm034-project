% The function first filters the eye mask using a given interval.
% It then uses the mouth location to continue the filtering by
% creating subregions for potential left and right eyes respectively.

function [leftEye, rightEye] = eye_regions(eye_mask, mouthRegion)

eye_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Orientation', 'Circularity');
img_size = size(eye_mask);
img_y = img_size(1);
img_x = img_size(2);

if(isempty(mouthRegion))
    %%Do nothing for now.
    for k = 1:length(eye_regions)
        eyeX = eye_regions(k).Centroid(1);
        eyeY = eye_regions(k).Centroid(2);
        orientation = eye_regions(k).Orientation;
        circularity = eye_regions(k).Circularity;

        if (eyeY < 3/5*img_y && eyeY > 2/5*img_y && eyeX > 1.5/9*img_x && eyeX < 6.4/9*img_x && orientation ~= 0 && circularity ~= inf && circularity > 0.3)
            %%Do nothing
        else
            bound = eye_regions(k).BoundingBox();

            bx = int64(bound(1)); % Pos X
            by = int64(bound(2)); % Pos Y
            bw = int64(bound(3)); % Width X
            bh = int64(bound(4)); % Height Y
            eye_mask(by:by+bh,bx:bx+bw) = 0;
        end
    end

    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');

    if length(found_regions) > 2
        %% Iterate through all regions and search for neighbours.
        for i = 1:length(found_regions)-1
            for j = i+1 : length(found_regions)
                xCoords(1) = found_regions(i).Centroid(1);
                xCoords(2) = found_regions(j).Centroid(1);
                yCoords(1) = found_regions(i).Centroid(2);
                yCoords(2) = found_regions(j).Centroid(2);
                xDistance = abs(xCoords(1) - xCoords(2));
                yDistance = abs(yCoords(1) - yCoords(2));

                neighbourFound = false;

                %% Neighbour found?
                if (xDistance < 24 && yDistance < 24)
                    neighbourFound = true;
                end

                %% Merge the regions as average.
                if(neighbourFound)
                    xAverage = int64(mean(xCoords));
                    yAverage = int64(mean(yCoords));

                    bound = found_regions(i).BoundingBox();
                    bx = int64(bound(1)); % Pos X
                    by = int64(bound(2)); % Pos Y
                    bw = int64(bound(3)); % Width X
                    bh = int64(bound(4)); % Height Y
                    eye_mask(by:by+bh,bx:bx+bw) = 0;

                    bound = found_regions(j).BoundingBox();
                    bx = int64(bound(1)); % Pos X
                    by = int64(bound(2)); % Pos Y
                    bw = int64(bound(3)); % Width X
                    bh = int64(bound(4)); % Height Y
                    eye_mask(by:by+bh,bx:bx+bw) = 0;

                    eye_mask(yAverage, xAverage) = 1;
                    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
                    break;
                end
            end
        end
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
    end
    if length(found_regions) > 2
        min_k = 0.07;
        best_match1 = [0 0];
        best_match2 = [0 0];

        idx_matches = 1;

        % Filtrera ut rimliga ögonpar, baserat på dess vågräthet
        for i = 1:length(found_regions)-1
            for j = i+1 : length(found_regions)
                xy1 = found_regions(i).Centroid();
                xy2 = found_regions(j).Centroid();
                x1 = xy1(1);
                x2 = xy2(1);
                y1 = xy1(2);
                y2 = xy2(2);

                if abs(x2-x1) < 70 || abs(x2-x1) >= 150
                    %%Do nothing
                else
                    k_angle =   abs((y2-y1) / (x2-x1));

                    if k_angle <= min_k
                        min_k = k_angle;
                        best_match1 = [x1 y1];
                        best_match2 = [x2 y2];
                        goodMatches(idx_matches , 1) = x1;
                        goodMatches(idx_matches , 2) = y1;
                        goodMatches(idx_matches , 3) = x2;
                        goodMatches(idx_matches , 4) = y2;
                        goodMatches(idx_matches , 5) = found_regions(i).Area();
                        goodMatches(idx_matches , 6) = found_regions(j).Area();
                        idx_matches = idx_matches +1;
                    end
                end
            end
        end
        closest = inf;
        biggest = 0;

        % Hitta bästa paret av alla "godkända par"
        for i = 1:idx_matches-1
            x1 = goodMatches(i,1);
            y1 = goodMatches(i,2);
            x2 = goodMatches(i,3);
            y2 = goodMatches(i,4);
            a1 = goodMatches(i,5);
            a2 = goodMatches(i,6);
            center = (2/5*img_y  +3/5*img_y)/2;

            if  abs(center - (y1+y2)/2) < closest

                best_match1 = [x1,y1];
                best_match2 = [x2,y2];
                closest = 3/5*img_y - (y1+y2)/2;
            end
        end

        for i = 1:length(found_regions)
            xy = found_regions(i).Centroid();
            should_delete = true;
            for j = 1:idx_matches-1
                x1 = goodMatches(j,1);
                y1 = goodMatches(j,2);
                x2 = goodMatches(j,3);
                y2 = goodMatches(j,4);

                if xy(1) == x1 && xy(2) == y1 || xy(1) == x2 && xy(2) == y2
                    should_delete = false;
                end
            end
            if should_delete
                bound = found_regions(i).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
        end

        for i = 1:length(found_regions)
            xy = found_regions(i).Centroid();

            if (xy(1) == best_match1(1) && xy(2) == best_match1(2)) || (xy(1) == best_match2(1) && xy(2) == best_match2(2))
                %%Do nothing
            else
                bound = found_regions(i).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
        end
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
    end
elseif(isempty(eye_regions))
    found_regions.Centroid = [0, 0];
else
    mouthX = mouthRegion.Centroid(1);
    mouthY = mouthRegion.Centroid(2);
    %% Remove all objects above or below a specified height of the image
    %% and that is not "close enough" to the mouth (compare x-coordinate).
    for k = 1:length(eye_regions)
        eyeY = eye_regions(k).Centroid(2);
        eyeX = eye_regions(k).Centroid(1);
        leftOfMouth = mouthX - 0.20*img_x; %% 20% to the left of the mouth.
        rightOfMouth = mouthX + 0.24*img_x; %% 24% to the right of the mouth.
        upperLimit = mouthY - 0.12*img_size(1);
        if ((eyeY < 3/5*img_y && eyeY > 2/5*img_y) && (eyeX > leftOfMouth && eyeX < rightOfMouth) && (eyeY < upperLimit))
            %%Do nothing
        else
            bound = eye_regions(k).BoundingBox();

            bx = int64(bound(1)); % Pos X
            by = int64(bound(2)); % Pos Y
            bw = int64(bound(3)); % Width X
            bh = int64(bound(4)); % Height Y
            eye_mask(by:by+bh,bx:bx+bw) = 0;
        end
    end

    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area', 'Orientation');

    eye_mask_copy = eye_mask;
    %% More than two regions? Continue filtering!
    if(length(found_regions) > 2)
        MIN_AREA = 30;
        %% Remove objects with to small area.
        for k = 1:length(found_regions)
            area = found_regions(k).Area();
            if(area <= MIN_AREA)
                bound = found_regions(k).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
        end
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area', 'Orientation');
    end

    %% Did we remove to much? step back once and try something else.
    if(length(found_regions) < 2)
        eye_mask = eye_mask_copy;
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox');
        clear eye_mask_copy;

        for k = 1:length(found_regions)
            eyeX = found_regions(k).Centroid(1);
            leftOfMouth = mouthX - 0.12*img_x; %% 12% to the left of the mouth.
            rightOfMouth = mouthX + 0.12*img_x; %% 12% to the right of the mouth.
            if (eyeX > leftOfMouth && eyeX < rightOfMouth)
                %%Do nothing
            else
                bound = found_regions(k).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
        end
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
    end



    %% More than two regions? Continue filtering!
    if(length(found_regions) > 2)

        %% Split found regions into potential left and right eyes.
        %% Left side
        left = true;
        eye_mask = left_or_right_region(eye_mask, mouthRegion, left);

        %% Right side
        left = false;
        eye_mask = left_or_right_region(eye_mask, mouthRegion, left);
    end
    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
end

%% Verify the regions
if(length(found_regions) == 2)
    xCoords(1) = found_regions(1).Centroid(1);
    xCoords(2) = found_regions(2).Centroid(1);
    xDistance = abs(xCoords(1) - xCoords(2));
    if(xDistance < 20)
        yCoords(1) = found_regions(1).Centroid(2);
        yCoords(2) = found_regions(2).Centroid(2);

        [~,idx] = sort(yCoords, 'ascend');
        bound = found_regions(idx(1)).BoundingBox();

        bx = int64(bound(1)); % Pos X
        by = int64(bound(2)); % Pos Y
        bw = int64(bound(3)); % Width X
        bh = int64(bound(4)); % Height Y
        eye_mask(by:by+bh,bx:bx+bw) = 0;
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
    end
end

%% Did we find two regions?
if(isempty(found_regions))
    leftEye = [0,0];
    rightEye = [0,0];

    %% Ugly code to add another eye region.
elseif (length(found_regions) == 1)
    xCoord = found_regions(1).Centroid(1);
    yCoord = found_regions(1).Centroid(2);
    rightEye = [xCoord, yCoord];
    leftEye = [xCoord - 0.15*img_x, yCoord];
elseif (length(found_regions) > 2)
    for k = 1:length(found_regions)
        area(k) = found_regions(k).Area();
    end
    [~, idx] = sort(area, 'ascend');
    for k = 1:length(found_regions) - 2
        bound = found_regions(idx(k)).BoundingBox();
        bx = int64(bound(1)); % Pos X
        by = int64(bound(2)); % Pos Y
        bw = int64(bound(3)); % Width X
        bh = int64(bound(4)); % Height Y
        eye_mask(by:by+bh,bx:bx+bw) = 0;
    end
    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
    xCoords(1) = found_regions(1).Centroid(1);
    xCoords(2) = found_regions(2).Centroid(1);

    [~, idx] = sort(xCoords, 'ascend');

    leftEye = found_regions(idx(1)).Centroid();
    rightEye = found_regions(idx(2)).Centroid();
else
    xCoords(1) = found_regions(1).Centroid(1);
    xCoords(2) = found_regions(2).Centroid(1);

    [~, idx] = sort(xCoords, 'ascend');

    leftEye = found_regions(idx(1)).Centroid();
    rightEye = found_regions(idx(2)).Centroid();
end