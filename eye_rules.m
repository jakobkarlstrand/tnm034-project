%%This function apply the following rules on the image.
% • The solidity of the region is greater than 0.5
% • The aspect ratio is between 0.8 and 4.0
% • The connected region is not touching the border
% • The orientation of the connected component is between
% -45 and +45 degree

function [outImage] = eye_rules(inImage)
Threshold = 0.5;
regions = regionprops(inImage, 'Solidity', 'BoundingBox', 'Orientation', 'PixelList');
outImage = imclearborder(inImage); %%Remove objects touching the border.

for k=1:length(regions)
    Solidity = regions(k).Solidity(); %%Should be larger than 0.5
    bound = regions(k).BoundingBox();
    width = uint8(bound(3)); 
    height = uint8(bound(4));
    aspectRatio = width/height; %%Should be between 0.4 and 0.8
    Orientation = regions(k).Orientation();

    if((Solidity > Threshold) && (aspectRatio > 0.4 ||aspectRatio < 0.8) ...
            && (Orientation > -45 || Orientation < 45))
        region = regions(k).PixelList();
        outImage(region) = 0;
    end
end

end