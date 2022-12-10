function [eye_mask] = left_or_right_region(eye_mask, mouthRegion, left)
i = 0;
j = 0;
img_size = size(eye_mask);
img_x = img_size(2);
mouthX = mouthRegion.Centroid(1);
potentialEyesIndex = [];
allIndices = [];
found_regions = regionprops(eye_mask, 'Centroid', 'BoundingBox', 'Area');
if(left)
    sideOfMouth = mouthX - 0.12*img_x; %% 12% to the left of the mouth.
else
    sideOfMouth = mouthX + 0.12*img_x; %% 12% to the right of the mouth.
end

potentialFound = false;
for m = 1:length(found_regions)
    eyeX = found_regions(m).Centroid(1);
    if(left)
        if(mouthX > eyeX)
            if(eyeX > sideOfMouth)
                i = i + 1;
                potentialEyesIndex(i) = m;
                potentialFound = true;
            end
            j = j + 1;
            allIndices(j) = m;
        end
    else
        if(mouthX < eyeX)
            if(eyeX < sideOfMouth)
                i = i + 1;
                potentialEyesIndex(i) = m;
                potentialFound = true;
            end
            j = j + 1;
            allIndices(j) = m;
        end
    end
end

%% If we did not find any potential eyes, try changing the  conditions.
if(~potentialFound)
    for k = 1:length(found_regions)
        eyeX = found_regions(k).Centroid(1);
        if(left)
            if(mouthX > eyeX)
                i = i + 1;
                potentialEyesIndex(i) = k;
            end
        else
            if(mouthX < eyeX)
                i = i + 1;
                potentialEyesIndex(i) = k;
            end
        end
    end
end

%% Pick the region with maximum area.

if(length(potentialEyesIndex) >= 1)
    area = zeros(1, length(potentialEyesIndex));
    for k = 1:length(potentialEyesIndex)
        area(k) = found_regions(potentialEyesIndex(k)).Area();
    end

    area = max(area);
    for k = 1:length(potentialEyesIndex)
        if(found_regions(potentialEyesIndex(k)).Area() == area)
            xCoords = found_regions(potentialEyesIndex(k)).Centroid(1);
            yCoords = found_regions(potentialEyesIndex(k)).Centroid(2);
        end
    end

    for k = 1:length(allIndices)
        for i = 1:length(potentialEyesIndex)
            if(potentialEyesIndex(i) ~= allIndices(k))
                bound = found_regions(allIndices(k)).BoundingBox();
                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                eye_mask(by:by+bh,bx:bx+bw) = 0;
            end
        end
    end
    bx = int64(xCoords);
    by = int64(yCoords);
    eye_mask(by,bx) = 1;
end
