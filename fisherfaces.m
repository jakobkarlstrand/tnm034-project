%%This function groups facial images of same individuals into classes,
%%minimize intra-class variance and maximize inter-class variance. Or...
%%atleast i think it does :)

function [F, weight] = fisherfaces(allFaces)

M = length(allFaces); %%Number of images
c = 16; %%number of persons
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

%%Sorting and eliminating small eigenvalues 
eigenVec = [];
for i = M : -1 : c + 1
    eigenVec = [eigenVec v(:,i)];
end

u = A*eigenVec; %%eigenfaces

V = zeros(M-c, M);
for i = 1 : M
    V(:,i) = u'*A(:,i);
end

m_projected = mean(V,2);
m = zeros(M-c,c);
Sw = zeros(M-c, M-c); %%Initialization os Within scatter matrix
Sb = zeros(M-c, M-c); %%Initialization of Between scatter matrix
classPopulation = 2; %%Number of images of person i. Idk how to solve this...
 
for i = 1 : c-1
    m(:,i) = mean((V(:,((i-1)*classPopulation+1):i*classPopulation)), 2)'; 
    Sb = Sb + (m(:,i) - m_projected) * (m(:,i) - m_projected)'; %%Between scatter matrix
       %%Idk vad som händer
       S  = zeros(M-c, M-c); 
       for j = ((i-1)*classPopulation+1):(i*classPopulation)
        S = S + (V(:,j)-m(:,i)) * (V(:,j)-m(:,i))';
       end

    Sw = Sw + S; %%Within scatter matrix.
end

%%Maximise the Between Scatter Matrix, while minimising the Within Scatter Matrix.
[W_eigenvectors, W_eigenvalues] = eig(Sb,Sw);

%%Sort the eigenvalues in descending order => Index = M, M-1, M-2...
W_eigenvalues = diag(W_eigenvalues);
[~, index] = sort(W_eigenvalues, 'descend');

U = zeros(M-c, c-1);
for i = 1 : c-1
    U(:,i) = W_eigenvectors(:,index(i)); %%Eigenfaces. Should be of size (M-c) x (c-1)
end

%F = zeros(M, c-1); Can't uncommon this, here is why:
%F is not of size M x c-1 because the number of images for each person is
%not the same. Idk how to solve that part.
for i = 1 : c * classPopulation
    F(i,:) = U' * V(:,i); %%Should be of size M x (c - 1)
end

%%Calculate weights
weight = zeros(M, c-1); %%Allocate space
for i = 1 : M
    for j = 1 : c-1
       if(i == 1)
           u(:,j) = u(:,j)/norm(u(:,j)); %%Normalize
       end
       weight(i,j) = u(:,index(j))'* x{i};
    end
end