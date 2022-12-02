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

%%Sorting and eliminating small eigenvalues 
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

%%For each person
for i = 1 : c
    personIndices = Index(i,:);
    personIndices = nonzeros(personIndices); %%Store index for each image of current person.
    classPolulation = length(personIndices); %%number of images of current person.
    averageCurrentPerson = zeros(N(1)*N(2),1); %%Allocate space

    %%Calculate projected average face of current person.
    for j = 1:classPolulation
        averageCurrentPerson = averageCurrentPerson + (1/classPolulation) * x{personIndices(j)};
    end
    averagePerson = (u'*averageCurrentPerson);

    Sb = Sb + (classPolulation * (averagePerson - globalAverage) * (averagePerson - globalAverage)'); %%Between scatter matrix
    A_person = zeros(M-c, classPolulation);
    for k = 1:classPolulation
        A_person(:,k) = V(:,personIndices(k)) - averagePerson; %%remove average from each image of the current person.
    end
    Sw = Sw + (A_person * A_person'); %%Within scatter matrix
end

%%Maximise the Between Scatter Matrix, while minimising the Within Scatter Matrix.
[W_eigenvectors, W_eigenvalues] = eig(Sb,Sw);

%%Sort the eigenvalues in descending order => Index = M, M-1, M-2...
W_eigenvalues = diag(W_eigenvalues);
[~, index] = sort(W_eigenvalues, 'descend');

U = zeros(M-c, c-1);
for i = 1 : c-1
    U(:,i) = W_eigenvectors(:,index(i));
end

F = zeros(N(1)*N(2), c-1);

for i = 1 : c - 1
   F(:,i) = u*U(:,i);
end

%%Calculate weights
weight = zeros(c-1, M); %%Allocate space
for i = 1 : M
    weight(:,i) = F'*x{i};
end