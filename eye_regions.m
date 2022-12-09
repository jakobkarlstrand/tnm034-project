% The function first filters the eye mask using a given interval. 
% It then uses the mouth location to continue the filtering by 
% creating subregions for potential left and right eyes respectively. 
% From the potential regions the function calculates an average location for the left and right eye respectively.

function [found_regions] = eye_regions(eye_mask, mouthRegion)

eye_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox');
img_size = size(eye_mask);
img_y = img_size(1);
img_x = img_size(2);

if(isempty(mouthRegion))
    %%Do nothing for now.
    %%Put your code here.
    found_regions.Centroid = [0, 0];
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
        leftOfMouth = mouthX - 0.12*img_x; %% 15% to the left of the mouth.
        rightOfMouth = mouthX + 0.12*img_x; %% 15% to the right of the mouth.
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

    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');

    %% More than two regions? Continue filtering!
    if(length(found_regions) > 2)
        MIN_AREA = 25;
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
        found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
    end



    %% More than two regions? Continue filtering!
    if(length(found_regions) > 2)

        %% Split found regions into potential left and right eyes.
        i = 0;
        j = 0;
        for k = 1:length(found_regions)
            xEye = found_regions(k).Centroid(1);
            if(mouthX > xEye)
                i = i + 1;
                potentialLeftEyesIndex(i) = k;
            else
                j = j + 1;
                potentialRightEyesIndex(j) = k;
            end
        end

        %% Calculate average for both of the sides.

        %% Left side
        if(length(potentialLeftEyesIndex) > 1)
            yCoords = zeros(1, length(potentialLeftEyesIndex));
            xCoords = zeros(1, length(potentialLeftEyesIndex));
            for k = 1:length(potentialLeftEyesIndex)
                xCoords(k) = found_regions(potentialLeftEyesIndex(k)).Centroid(1);
                yCoords(k) = found_regions(potentialLeftEyesIndex(k)).Centroid(2);
            end

            xAverage = mean(xCoords);
            yAverage = mean(yCoords);

            for k = 1:length(potentialLeftEyesIndex)
                bound = found_regions(potentialLeftEyesIndex(k)).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
            bx = int64(xAverage);
            bw = int64(img_x*0.03); % Width X
            bh = int64(img_y*0.03); % Height Y
            by = int64(yAverage);
            eye_mask(by:by+bh,bx:bx+bw) = 1;
        end

        % Right side
        if(length(potentialRightEyesIndex) > 1)
            yCoords = zeros(1, length(potentialRightEyesIndex));
            xCoords = zeros(1, length(potentialRightEyesIndex));
            for k = 1:length(potentialRightEyesIndex)
                xCoords(k) = found_regions(potentialRightEyesIndex(k)).Centroid(1);
                yCoords(k) = found_regions(potentialRightEyesIndex(k)).Centroid(2);
            end

            xAverage = mean(xCoords);
            yAverage = mean(yCoords);

            for k = 1:length(potentialRightEyesIndex)
                bound = found_regions(potentialRightEyesIndex(k)).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
            bx = int64(xAverage);
            bw = int64(img_x*0.03); % Width X
            bh = int64(img_y*0.03); % Height Y
            by = int64(yAverage);
            eye_mask(by:by+bh,bx:bx+bw) = 1;
        end
    end

    found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
end