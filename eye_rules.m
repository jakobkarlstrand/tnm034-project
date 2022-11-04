%%This function apply the following rules on the image.
% • The solidity of the region is greater than 0.5
% • The aspect ratio is between 0.8 and 4.0
% • The connected region is not touching the border
% • The orientation of the connected component is between
% -45 and +45 degree

function [outImage] = eye_rules(inImage)
Threshold = 0.5;
regions = regionprops(inImage, 'Solidity', 'BoundingBox');

% TODO
% • The solidity of the region is greater than 0.5.
% • The aspect ratio is between 0.8 and 4.0.
% • The orientation of the connected component is between. 
% -45 and +45 degree

for k=1:length(regions)
Solidity = regions(k).Solidity();
bound = regions(k).BoundingBox();
    
bx = uint8(bound(1)); % Pos X
by = uint8(bound(2)); % Pos Y
bw = uint8(bound(3)); % Width X
bh = uint8(bound(4)); % Height Y

regionMask(by:by+bh,bx:bx+bw) = Solidity > Threshold

end

%outImage = regionMask;
outImage = imclearborder(inImage); %%Remove objects touching the border.
end