function [finalImage] = lighting_compensation(currentImage, top_percentage)
%Corrects inbalance in the RGB channels based on white patch and contrast
%streching of the G color channel
%top_percentage - specifies white patch based on max percentage of image
%figure;
%imshow(currentImage)

R = currentImage(:,:,1);
G = currentImage(:,:,2);
B = currentImage(:,:,3);

G = (G - min(G(:)))/(max(G(:)) - min(G(:))); %Contrast streching of G

%Get pixel count in each color channel 
n_pixels = length(reshape(R.',1,[]));

%Get a array of the X% highest pixel values in each color channel
R_max = maxk(reshape(R.',1,[]), round(n_pixels * top_percentage));
G_max = maxk(reshape(G.',1,[]), round(n_pixels * top_percentage));
B_max = maxk(reshape(B.',1,[]), round(n_pixels * top_percentage));

%Calculate the mean of the X% highest pixel values for each color channel
R_max_mean = mean(R_max);
G_max_mean = mean(G_max);
B_max_mean = mean(B_max);


%Calc correction multiplier based on G
R_multiplier = G_max_mean./R_max_mean;
B_multiplier = G_max_mean./B_max_mean;

%Correct B and R
B = B .* B_multiplier;
R = R .* R_multiplier;

%figure;
finalImage(:,:,1) = R;
finalImage(:,:,2) = G;
finalImage(:,:,3) = B;
%imshow(finalImage)

end

