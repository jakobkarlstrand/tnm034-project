function [I] = compute_eigenFace(allFaces)

M = length(allFaces);
N = size(allFaces{1});

%%Compute average of all faces
average = compute_mean_face(allFaces);
copyAllFaces = allFaces; %%Make a copy of in case we need all faces later.

%%For each face, remove the average face and reshape image to N^2 x 1. 
A = zeros(N(1)*N(2), M); %%Allocate space
for i = 1:M
    copyAllFaces{i} = rgb2gray(copyAllFaces{i} - average); %%Remove average
    copyAllFaces{i} = reshape(copyAllFaces{i},1,[]); %%Reshape into NxN vector
    A(:,i) = copyAllFaces{i}(:); %%Store the image vector in A. 
end

%%Compute covariance matrix of size MxM
C = A'*A;

[eigenVectors, eigenValues] = eig(C); %%calculates eigenvalues and eigenvectors of C.
v = eigenVectors; %%easier to read.

u = A*v; %%step 7 of PCA according to slides.
eigenFaces = cell(1,M); %%Allocate space

%%Reshaping the n-dim eigenvectors u into matrices will give the Eigenfaces
for j = 1:M
    eigenFaces{j} = reshape(u(:,j), N(1), N(2));
end

%%Sort the eigenvalues in descending order => Index = M, M-1, M-2...
eigenValues = diag(eigenValues);
[~, index] = sort(eigenValues, 'descend');

numberOfEigenFaces = 4; %%used to only get the best eigenfaces.
weight = cell(M, numberOfEigenFaces); %%Allocate space
%%calculate weights
for i = 1:M
    for j = 1:numberOfEigenFaces
        weight{i,j} = eigenFaces{index(j)}.*(allFaces{i} - average);
    end
end

%%compute the linear combination of each original face
I = cell(1, M); %%Allocate space
for i = 1:M
    for j = 1:numberOfEigenFaces
        I{i} = average + sum(weight{i,j}.*eigenFaces{j});
    end
end