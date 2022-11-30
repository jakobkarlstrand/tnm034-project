%%This function groups facial images of same individuals into classes,
%%minimize intra-class variance and maximize inter-class variance. Or...
%%atleast i think it does :)

function [F, weight] = fisherfaces(imagefiles, allFaces)

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

%%Group images of same person
FileName = {imagefiles.name};
[~, person] = (strtok(FileName, '_'));

Index = zeros(M, 4);
for iName = 1:numel(person)
    match = endsWith(FileName, [person{iName}, (strtok(FileName, '_'))]);
    temp = find(match);
    Index(iName, 1:length(temp)) = temp;
    Index = unique(Index, 'rows', 'stable'); %%Remove duplicates.
end
Index = Index(any(Index,2),:); %%Remove rows that only contains zeros.

m_projected = mean(V,2);
Sw = zeros(M-c, M-c); %%Initialization of Within scatter matrix
Sb = zeros(M-c, M-c); %%Initialization of Between scatter matrix

%%For each person
for i = 1 : c-1
    personIndices = Index(i,:);
    personIndices = nonzeros(personIndices);
    classPolulation = length(personIndices); %%number of images of current person.
    averagePerson = zeros(N(1)*N(2),1); 
    y = cell(1, classPolulation); 
    A_new = zeros(N(1)*N(2), classPolulation);

    figure;
    for j = 1:classPolulation
        y{j} = rgb2gray(allFaces{personIndices(j)}); %%Convert to gray scale.
        subplot(1, classPolulation, j);
        imshow(y{j});
        y{j} = reshape(y{j},[],1); %%Reshape into NxN vector.
        averagePerson = averagePerson  + (1/classPolulation) * y{j}; %%Calculate average face vector.
    end
    sgtitle('Images of person');

    for l = 1:classPolulation
        phi_new{l} = y{l} - averagePerson; %%Subtract average face from each face vector.
        A_new(:,l) = phi_new{l}; %%Store the image vector in A.
    end

    for l = 1 : classPolulation
        V_new(:,l) = u'*A_new(:,l);
    end

    averagePerson_projected = u'*averagePerson;

%     figure;
%     averagePerson = reshape(averagePerson, N(1), N(2));
%     imshow(averagePerson);
%     title('Average of person');

    Sb = Sb + (classPolulation * (averagePerson_projected - m_projected) * (averagePerson_projected - m_projected)'); %%Between scatter matrix
    A_person = zeros(M-c, classPolulation);
    for k = 1:classPolulation
        A_person(:,k) = V_new(:,k) - averagePerson_projected;
    end
    Sw = Sw + A_person * A_person';
end

Sb
Sw

%%Maximise the Between Scatter Matrix, while minimising the Within Scatter Matrix.
[W_eigenvectors, W_eigenvalues] = eig(Sb,Sw);

%%Sort the eigenvalues in descending order => Index = M, M-1, M-2...
W_eigenvalues = diag(W_eigenvalues);
[~, index] = sort(W_eigenvalues, 'descend');

U = zeros(M-c, c-1);
for i = 1 : c-1
    U(:,i) = W_eigenvectors(:,index(i)); %%Eigenfaces. Should be of size (M-c) x (c-1)
end

F = zeros(N(1)*N(2), c-1);
for i = 1 : c - 1
  %  F(i,:) =....
end

%%Calculate weights
weight = zeros(N(1)*N(2), c-1); %%Allocate space
for i = 1 : M
    weight = F'*x{i};
end