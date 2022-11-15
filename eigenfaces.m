function [] = eigenfaces(images)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[height, width, chans] = size(images{1});


%Convert all images to vector
for j = 1:length(images)
    %%Convert image to vector
    image =  rgb2gray(images{j});

    image_vector = reshape(image, height*width, 1);
    
    %Add to final matrix
    images_vectors{j} =  image_vector;
end

n = height * width;
M = length(images_vectors);
images_vectors{1};
size(images_vectors{1})
images = cell2mat(images);


%Calculate average 
avg_image = zeros(n,1);
size(avg_image);
for j = 1:M
    avg_image = avg_image + (1/M) * images_vectors{j};
end

figure,imshow(reshape(avg_image,height,width));title('average');

%Subtract mean from each image vector

for j = 1:M
    images_vectors{j} = images_vectors{j} - avg_image;
    %figure,imshow(reshape(images_vectors{j},height,width));
end

%Find the covariance matrix

%for j = 1:M
%    C = transpose(images_vectors{j})*images_vectors{j};
%end
images_vectors = cell2mat(images_vectors);
C = images_vectors'*images_vectors;

disp("C: ")
size(C)

%Find the eigenfaces
[Veigvec, Deigval] = eig(C);

Veigvec

Vlarge = images_vectors*Veigvec;

for k=1:M
    eigenfaces{k} = reshape(Vlarge(:,k),height,width);
end
eigenfaces = cell2mat(eigenfaces);


weigths = eigenfaces'.*(images-reshape(avg_image,height,width));
disp("weigths");
size(weigths)

x=diag(Deigval)
[xc,xci] = sort(x, 'descend');

for k=1:M
    z{k} = eigenfaces{xci(k)}; 
    figure,imshow(z{k});
end


disp("z:");
size(z{1})
testbild = zeros(height, width);
for j=1:16
    testbild = testbild + weigths(j) .* z{j};
end
linear = zeros(height, width,16);

for j = 1:16
    for k = 1:16
        linear(:,:,j) = linear(:,:,j) + (weigths(j,k)*z{k});
    end
    linear(:,:,j) = linear(:,:,j) + reshape(avg_image,height,width);
    figure,imshow(linear(:,:,j));title('linear combination' + j);
end

%testbild = testbild + (weigths(2) .* z{2});

%testbild = testbild + reshape(avg_image,height,width);

%figure,imshow(testbild);




