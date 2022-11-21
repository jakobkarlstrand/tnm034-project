function [binary_image] = eye_detect_circular(inputImage)

[centers, radii, metric] = imfindcircles(inputImage,[6 10]);

centersStrong5 = centers(:,:); 
radiiStrong5 = radii(:);
metricStrong5 = metric(:);

imshow(inputImage)
hold on
viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
hold off



end

