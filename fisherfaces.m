%%This function groups facial images of same individuals into classes,
%%minimize intra-class variance and maximize inter-class variance. Or...
%%atleast i think it does :)

function [F, u, weight] = fisherfaces(imagefiles, allFaces)

M = length(allFaces); %%Number of images
N = size(allFaces{1});

%%Group images of same person and calculate number of persons
FileName = {imagefiles.name};
[~, person] = (strtok(FileName, '_'));

Index = zeros(M, 4); %%Allocate space
for iName = 1:numel(person)
    match = endsWith(FileName, [person{iName}, (strtok(FileName, '_'))]);
    temp = find(match);
    Index(iName, 1:length(temp)) = temp;
    Index = unique(Index, 'rows', 'stable'); %%Remove duplicates.
end
Index = Index(any(Index,2),:); %%Remove rows that only contains zeros.
c = size(Index);
c = c(1); %%number of persons;

%%allocate space.
x = cell(1, M); 
averageFace = zeros(N(1)*N(2),1); 

figure;
%%For each face, reshape into NxN vector and calculate average.
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

%%Sorting and eliminating small eigenvalues. We want the M-c largest
%%eigenvectors
[~,ind] = sort(eigenValues, 'descend');
eigenVec = eigenVectors(:,ind);
eigenVec = eigenVec(:,1:M-c);

u = A*eigenVec; %%eigenfaces
V = zeros(M-c, M);

for i = 1 : M
    V(:,i) = u'*A(:,i);
end

globalAverage = (u'*averageFace); %%Projected global average
Sw = zeros(M-c, M-c); %%Initialization of Within scatter matrix
Sb = zeros(M-c, M-c); %%Initialization of Between scatter matrix
averageCurrentPerson = zeros(N(1)*N(2),c); %%Allocate space
figure;
%%For each person
for i = 1 : c
    personIndices = Index(i,:);
    personIndices = nonzeros(personIndices); %%Store index for each image of current person. 
    classPolulation = length(personIndices); %%number of images of current person.

    %%Calculate projected average face of current person.
    for j = 1:classPolulation
        averageCurrentPerson(:,i) = averageCurrentPerson(:,i) + (1/classPolulation) * x{personIndices(j)};
    end
    averagePersonProjected = (u'*averageCurrentPerson(:,i));

    Sb = Sb + (classPolulation * (averagePersonProjected - globalAverage) * (averagePersonProjected - globalAverage)'); %%Between scatter matrix
    A_person = zeros(M-c, classPolulation);
    for k = 1:classPolulation
        A_person(:,k) = V(:,personIndices(k)) - averagePersonProjected; %%remove average from each image of the current person.
    end
    Sw = Sw + (A_person * A_person'); %%Within scatter matrix
end

%%Maximise the Between Scatter Matrix, while minimising the Within Scatter Matrix.
[W_eigenvectors, W_eigenvalues] = eig(Sb,Sw);

%%Sort the eigenvalues in descending order => Index = M, M-1, M-2...
W_eigenvalues = diag(W_eigenvalues);
[~, index] = sort(W_eigenvalues, 'descend');
U = W_eigenvectors(:,index);
U = U(:,1:c-1);

F = zeros(N(1)*N(2), c-1);

figure;
for i = 1 : c - 1
   F(:,i) = u*U(:,i);
    subplot(5,4,i);
    imshow(reshape(F(:,i),[245,177]))
end

%%Calculate weights
weight = zeros(c, c-1); %%Allocate space
for i = 1 : c
    weight(i,:) = F'*averageCurrentPerson(:,i);
end

index = [1, 2, 4, 5, 6, 7, 10, 13, 14, 3, 8, 9, 11, 12, 15, 16];

save('computedFisherData.mat', 'weight', 'u', 'index_images', 'F');