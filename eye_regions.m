% The function first filters the eye mask using a given interval.
% It then uses the mouth location to continue the filtering by
% creating subregions for potential left and right eyes respectively.
% From the potential regions the function calculates an average location for the left and right eye respectively.

function [found_regions] = eye_regions(eye_mask, mouthRegion)

eye_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Orientation', 'Circularity');
img_size = size(eye_mask);
img_y = img_size(1);
img_x = img_size(2);

if(isempty(mouthRegion))
    %%Do nothing for now.
    for k = 1:length(eye_regions)
        eyeY = eye_regions(k).Centroid(2);
        orientation = eye_regions(k).Orientation;
        circularity = eye_regions(k).Circularity;

        if (eyeY < 3/5*img_y && eyeY > 2/5*img_y  && orientation ~= 0 && circularity ~= inf && circularity > 0.3)
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