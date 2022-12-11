function id = tnm034(im)
%%im: Image of unknown face, RGB-image in uint8 format in the range [0,255]
%%id: The identity number (integer) of the identified person,
%%i.e. %1i, ‘2’,...,‘16’ for the persons belonging to ‘db1’ %
%%and 0’ for all other faces.

%% Load data
data = load('computedData.mat');
weight = data.weight; %%Weights
averageFace = data.averageFace; %%Average face
u = data.u; %%Best eigenvectors
index = data.index;

%% Preprocessing
prob = skinprobabilitymatrix();
im = lighting_compensation(im,0.2);
skin = skinmask(im, 0.03,prob);
EyeMap = eye_detection(im) & skin;
MouthMap = mouth_detection(im) & skin;
MouthRegions = mouth_regions(MouthMap);
[lEye, rEye] = eye_regions(EyeMap, MouthRegions); %%Compute eye location
[rotatedImage, lEyeRotated, rEyeRotated] = rotate_image(im, lEye, rEye); %%Rotate image.
croppedImage = crop_face(rotatedImage, lEyeRotated, rEyeRotated); %%Crop image

%% Convert image to vector
croppedImage = rgb2gray(croppedImage);
croppedImage = reshape(croppedImage,[],1);
phi = croppedImage - averageFace;

%% Calculate weights for current image
im_weight = zeros(1,16);
for j = 1:16
    im_weight(1,j) = u(:,index(j))'* phi;
end

%% Calculate minimum distance and image id
error = Inf; %%minimum distance
id = 0;

for i = 1:16
    sqrt(sum((im_weight - weight(i,:)).^2));
    if sqrt(sum((im_weight - weight(i,:)).^2)) < error
        error = sqrt(sum((im_weight - weight(i,:)).^2)); %%update minimum distance
        id = i; %%update id.
    end
end

%%Error threshold
if error > 16.7
    id = 0;
end

