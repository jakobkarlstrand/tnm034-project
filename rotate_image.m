%%The function takes the current image and the location of the eyes and
%%mouth as arguments. It uses Hough transform to rotate the image so that
%%the eyes are horizontal. 

function [currentImage_rotated, lEye_rotated, rEye_rotated, mouth_rotated] = rotate_image(currentImage, lEye, rEye, mouth)

%%Create a figure with the line connecting the eyes. 
figure('visible','off');
size_img = size(currentImage); %%get image size
lineImage = zeros(size_img(1), size_img(2));
imshow(lineImage);
hold on 
plot([lEye(1),rEye(1)],[lEye(2),rEye(2)],'Color','w','LineWidth',2)
hold off
title('Line to rotate');
set(gca,'XColor','none'); %%Remove borders for the image. 
F = getframe(gca); %%Take a snapshot of the image with the plot inside it.
[temp, Map] = frame2im(F); %%Save the snapshot in temp. 

temp = im2gray(temp); %%convert to grayscale for Hough transform. 
% figure;
% imshow(temp);
% title('Snapshot of image');

%%Hough transform.
[H, teta, ro] = hough(temp, "Rhoresolution", 5, "Theta", -90:0.5:89.5);
[r, t] = find(H == max(H(:)));
teta = teta(t(1));           

%%Determine if the rotation should be clockwise or counter clockwise
sign = 0;
if teta > 0
    sign = 1;
elseif teta < 0
    sign = -1;
end
rot_angle = teta - 90*sign; %% Angle of rotation.

% figure;
% lineImage_rotated = imrotate(temp, rot_angle, "bilinear", "crop");
% imshow(lineImage_rotated);
% title('Rotated line');

%%Rotate current image.
currentImage_rotated = imrotate(currentImage, rot_angle, "bilinear", "crop");

%%Apply rotation to eye and mouth location.
rotationMatrix = [cosd(rot_angle) sind(rot_angle); -sind(rot_angle) cosd(rot_angle)]; %%rotation matrix
centerOfImage = (size(currentImage(:,:,1))/2)'; %%Center of the image.

lEye_rotated = (rotationMatrix * (lEye' - centerOfImage) + centerOfImage)';
rEye_rotated = (rotationMatrix * (rEye' - centerOfImage) + centerOfImage)';
mouth_rotated = (rotationMatrix * (mouth' - centerOfImage) + centerOfImage)';

end