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
im = lighting_compensation(im,0.2);
EyeMap = eye_detection(im);
MouthMap = mouth_detection(im);

[lEye_c, rEye_c, mouth_c, ~, ~] = face_triangle_coordinates(MouthMap, EyeMap); %%Compute eye and mouth triangle.
[rotated_image, lEye_rotated, rEye_rotated, ~] = rotate_image(im, lEye_c, rEye_c, mouth_c);%%Rotate image.
cropped_image = crop_face(rotated_image, lEye_rotated, rEye_rotated);%%Crop image

%% Convert image to vector
cropped_image = rgb2gray(cropped_image);
cropped_image = reshape(cropped_image,[],1);
phi = cropped_image - averageFace;

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
