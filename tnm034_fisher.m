function id = tnm034(im)
%%im: Image of unknown face, RGB-image in uint8 format in the range [0,255]
%%id: The identity number (integer) of the identified person,
%%i.e. %1i, ‘2’,...,‘16’ for the persons belonging to ‘db1’ %
%%and 0’ for all other faces.

%% Load data
data = load('computedFisherData.mat');
dataSkin = load('skinProbabilityMatrixData.mat')
weight = data.weight; %%Weights
u = data.u; %%Best eigenvectors
F = data.F;
index = data.index;

%% Preprocessing
prob = dataSkin.skinMatrix;
im = lighting_compensation(im,0.2);
skin = skinmask(im, 0.1,prob);
EyeMap = eye_detection(im) & skin;
MouthMap = mouth_detection(im) & skin;
MouthRegions = mouth_regions(MouthMap);
[lEye, rEye] = eye_regions(EyeMap, MouthRegions); %%Compute eye location
[rotatedImage, lEyeRotated, rEyeRotated] = rotate_image(im, lEye, rEye); %%Rotate image.
croppedImage = crop_face(rotatedImage, lEyeRotated, rEyeRotated); %%Crop image

%% Convert image to vector
croppedImage = rgb2gray(croppedImage);
croppedImage = reshape(croppedImage,[],1);
phi = croppedImage;

%% Calculate weights for current image
im_weight = F'*phi;

%% Calculate minimum distance and image id
error = Inf; %%minimum distance
id = 0;

im_weight = im_weight';
weight(3,:);

for i = 1:16
    sqrt(sum((im_weight - weight(i,:)).^2));
    if sqrt(sum((im_weight - weight(i,:)).^2)) < error
        error = sqrt(sum((im_weight - weight(i,:)).^2)); %%update minimum distance
        id = index(i); %%update id.
    end
end

disp(error)

%%Error threshold
if error > 191
    id = 0;
end

