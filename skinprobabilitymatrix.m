function [prob_image] = skinprobabilitymatrix()
folder = "skin"; %%locate folder
imagefiles = dir(fullfile(folder,'*.jpg')); %%store the images
nfiles = length(imagefiles); %%define number of images.
Im = cell(1,nfiles); %%Allocate space

prob_image = zeros(256);

%Looping trough all skinmasks 
for i = 1:nfiles
  
  filename=fullfile(folder,imagefiles(i).name); %%get filename of current image.
  %%subplot(nfiles, nfiles, i); %%define location to plot the image in our subplot.
  Im{i}=im2double(imread(filename)); %%Read the imagefile, convert to double and store it.
  %%imshow(Im{i}) %%Show the current image in a subplot.  
    
  YCbCr = rgb2ycbcr(Im{i}); %%convert the first image in our folder to YCbCr.
  [Y, Cb, Cr] = imsplit(YCbCr); %%split the image into Y, Cb and Cr.'
  
  
  dim = size(Cb);
  size2 = dim(1) * dim(2);
  arrayCb = reshape(Cb.',1,size2);
  arrayCr = reshape(Cr.',1, size2);
  arrayY = reshape(Y.',1, size2);
  
  %%For each pixel in image i, add the Cb and Cr value to the prob_image
  for k = 1:numel(arrayCr)
      
      if arrayY(k) < 0.92 %%White pixels have value 0.9216
        prob_image(round(arrayCb(k)*255), round(arrayCr(k)*255)) = prob_image(round(arrayCb(k)*255), round(arrayCr(k)*255)) + 1;      end
     
  end

end
   
  prob_image = prob_image./max(prob_image(:));
  imwrite(prob_image, 'skinprobability.jpg');


end

