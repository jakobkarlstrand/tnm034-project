function [found_regions] = mouth_regions(mouth_mask)
mouth_regions_1 = regionprops(mouth_mask, 'Centroid', 'BoundingBox');
img_size = size(mouth_mask);
img_y = img_size(1);
img_x = img_size(2);
mouth_mask_temp = mouth_mask;
found_regions = [];
%% Remove all objects above or below a specified area of the image.
for k = 1:length(mouth_regions_1)
    mouthX = mouth_regions_1(k).Centroid(1);
    mouthY = mouth_regions_1(k).Centroid(2);

    if (mouthY > 3/5*img_y && mouthY <= 3.9/5*img_y) && (mouthX > 2/9*img_x && mouthX < 7/9*img_x)
        %%Do nothing
    else
        bound = mouth_regions_1(k).BoundingBox();

        bx = int64(bound(1)); % Pos X
        by = int64(bound(2)); % Pos Y
        bw = int64(bound(3)); % Width X
        bh = int64(bound(4)); % Height Y
        mouth_mask_temp(by:by+bh,bx:bx+bw) = 0;
    end
end

mouth_regions_stage1 = regionprops(mouth_mask_temp, 'Centroid', 'BoundingBox', 'Area');

%% Remove all objects above or below a specified area of the image.
if(length(mouth_regions_stage1) == 1)
    found_regions = mouth_regions_stage1;
else
    min_area = 1850;
    max_area = 3470;
    mouth_mask_temp2 = mouth_mask_temp;
    for k = 1:length(mouth_regions_stage1)
        area = mouth_regions_stage1(k).Area();

        if (area > min_area && area < max_area)
            %%Do nothing
        else
            bound = mouth_regions_stage1(k).BoundingBox();

            bx = int64(bound(1)); % Pos X
            by = int64(bound(2)); % Pos Y
            bw = int64(bound(3)); % Width X
            bh = int64(bound(4)); % Height Y
            mouth_mask_temp2(by:by+bh,bx:bx+bw) = 0;
        end
    end


    mouth_regions_stage2 = regionprops(mouth_mask_temp2, 'Centroid', 'BoundingBox', 'Area');

    %%If found 1 mouth region, do nothing.
    if (length(mouth_regions_stage2) == 1)
        found_regions = mouth_regions_stage2;
        %%Did not find any mouth regions, adjust the area.
    elseif (isempty(mouth_regions_stage2))
        min_area = 865;
        max_area = 1700;
        mouth_mask_temp2 = mouth_mask_temp;
        for k = 1:length(mouth_regions_stage1)
            area = mouth_regions_stage1(k).Area();

            if (area > min_area && area < max_area)
                %%Do nothing
            else
                bound = mouth_regions_stage1(k).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                mouth_mask_temp2(by:by+bh,bx:bx+bw) = 0;
            end
        end
        mouth_regions_stage2 = regionprops(mouth_mask_temp2, 'Centroid', 'BoundingBox', 'Area');
        found_regions = mouth_regions_stage2;
        %%Found more than one mouth region, adjust the area.
    else
        min_area = 1850;
        max_area = 2100;
        mouth_mask_temp3 = mouth_mask_temp2;
        reduced = false;
        for k = 1:length(mouth_regions_stage2)
            area = mouth_regions_stage2(k).Area();

            if (area > min_area && area < max_area)
                %%Do nothing
            else
                reduced = true;
                bound = mouth_regions_stage2(k).BoundingBox();

                bx = int64(bound(1)); % Pos X
                by = int64(bound(2)); % Pos Y
                bw = int64(bound(3)); % Width X
                bh = int64(bound(4)); % Height Y
                mouth_mask_temp3(by:by+bh,bx:bx+bw) = 0;
            end
        end
        mouth_regions_stage3 = regionprops(mouth_mask_temp3, 'Centroid', 'BoundingBox', 'Area');
        %%Did we reduce the number of mouth regions?
        if(reduced && length(mouth_regions_stage3) > 0)
            %%Do nothing
        else
            min_area = 2200;
            max_area = 3400;
            mouth_mask_temp3 = mouth_mask_temp2;
            for k = 1:length(mouth_regions_stage2)
                area = mouth_regions_stage2(k).Area();

                if (area > min_area && area < max_area)
                    %%Do nothing
                else
                    bound = mouth_regions_stage2(k).BoundingBox();

                    bx = int64(bound(1)); % Pos X
                    by = int64(bound(2)); % Pos Y
                    bw = int64(bound(3)); % Width X
                    bh = int64(bound(4)); % Height Y
                    mouth_mask_temp3(by:by+bh,bx:bx+bw) = 0;
                end
            end
        end
        mouth_regions_stage3 = regionprops(mouth_mask_temp3, 'Centroid', 'BoundingBox', 'Area');
        found_regions = mouth_regions_stage3;
    end
end