%%This function uses PCA to reduce the dimensionality of the dataset

function [I,weight, averageFace, u, index] = compute_eigenFace(allFaces)

M = length(allFaces);
N = size(allFaces{1});

%%allocate space.
x = cell(1, M); 
averageFace = zeros(N(1)*N(2),1); 

figure;
%%For each face, reshape into NxN vetor and calculate average.
for i = 1:M
    x{i} = rgb2gray(allFaces{i}); %%Convert to gray scale.
    x{i} = reshape(x{i},[],1); %%Reshape into NxN vector.
    averageFace = averageFace  + (1/M) * x{i}; %%Calculate average face vector.
end

%%allocate space.
phi = cell(1,M); 
A = zeros(N(1)*N(2), M); 

for i = 1:M
    phi{i} = x{i} - averageFace; %%Subtract average face from each face vector.
    A(:,i) = phi{i}; %%Store the image vector in A.
end



%%Compute covariance matrix of size MxM
C = A'*A;

[eigenVectors, eigenValues] = eig(C); %%calculates eigenvalues and eigenvectors of C.
v = eigenVectors; %%easier to read.

u = A*v; %%step 7 of PCA according to slides.


%%Display eigenfaces
% figure;
% for j = 1:M
%     eigenFaces = reshape(u(:,j), N(1), N(2));
%     subplot(4,4,j);
%     imshow(eigenFaces);
% end

%%Sort the eigenvalues in descending order => Index = M, M-1, M-2...
eigenValues = diag(eigenValues);
[~, index] = sort(eigenValues, 'descend');

numberOfEigenVectors = 12;  
weight = zeros(M, numberOfEigenVectors); %%Allocate space

%%calculate weights
for i = 1:M
    for j = 1:numberOfEigenVectors
       %%Only need to normalize once
       if(i == 1)
           u(:,index(j)) = u(:,index(j))/norm(u(:,index(j))); %%Normalize
       end
        weight(i,j) = u(:,index(j))'* phi{i};
    end
end

I = cell(1, M); %%Allocate space

%%compute the linear combination of each original face
for i = 1:M
    sum = 0;   
    for j = 1:numberOfEigenVectors
        sum = sum + weight(i,j)*u(:,index(j));
    end
    I{i} = averageFace + sum;
    I{i} = reshape(I{i}, N(1), N(2));
end