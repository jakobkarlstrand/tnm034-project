%%This function crops the rotated image. The cropped image should only
%%contain the face of the image


function [croppedImage] = crop_face(currentImage, lEye, rEye)

distance_between_eyes = abs(lEye - rEye); %%Distance between eyes
point_between_eyes = (distance_between_eyes / 2) + lEye; %%The point between the eyes

[height, width, chans] = size(currentImage); %%Get image size.
centerOfImage = [width/2, height/2]; %%Calculate center of x in image.
distance = centerOfImage - point_between_eyes; %%Distance between point between eyes and center.

translatedImage = imtranslate(currentImage, [distance(1), distance(2)]); %%Translate image

margin_above_eye = 0.8;
margin_under_eye = 1.7;
margin_right_left_eye = 0.9;

croppedImage = imcrop(translatedImage, [centerOfImage(1) - margin_right_left_eye*distance_between_eyes(1), centerOfImage(2) - margin_above_eye*distance_between_eyes(1), 2*margin_right_left_eye*distance_between_eyes(1), margin_above_eye*distance_between_eyes(1) + margin_under_eye*distance_between_eyes(1)] );
croppedImage = imresize(croppedImage, [245 177]);
end

