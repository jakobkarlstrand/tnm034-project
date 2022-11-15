%%This function calculates the mean face given an array of faces.

function [averageFace] = compute_mean_face(allFaces)

M = length(allFaces)
N = size(allFaces{1})
averageFace = zeros(N(1), N(2));
%% compute mean
for k=1:M
    allFaces{k} = im2single(allFaces{k});
    averageFace   = averageFace  + (1/M) * allFaces{k};
 
end

figure,imshow(averageFace);title('average');
end