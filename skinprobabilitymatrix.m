function [prob_image] = skinprobabilitymatrix()
folder = "skin"; %%locate folder
imagefiles = dir(fullfile(folder,'*.png')); %%store the images
nfiles = length(imagefiles); %%define number of images.
Im = cell(1,nfiles); %%Allocate space

%%for each image
for i = 1:nfiles
  filename=fullfile(folder,imagefiles(i).name); %%get filename of current image.
  subplot(nfiles, nfiles, i); %%define location to plot the image in our subplot.
  Im{i}=im2double(imread(filename)); %%Read the imagefile, convert to double and store it.
  imshow(Im{i}) %%Show the current image in a subplot.
end


prob_image = zeros(256);

for i = 1:nfiles
  YCbCr = rgb2ycbcr(Im{i}); %%convert the first image in our folder to YCbCr.
  [Y, Cb, Cr] = imsplit(YCbCr); %%split the image into Y, Cb and Cr.'
  
  if i == 1
     disp(Y) 
  end
  
  arrayCb = Cb';
  arrayCb = arrayCb(:)';
  arrayCr = Cr';
  arrayCr = arrayCr(:)';
  arrayY = Y';
  arrayY = arrayY(:)';
  
  pixels_rejected = 0;
  pixels = 0;
  
  for k = 1:numel(arrayCr)
      
      if arrayY(k) < 0.92 %%White pixels have value 0.9216
        pixels = pixels + 1;
        prob_image(round(arrayCb(k)*255), round(arrayCr(k)*255)) = prob_image(round(arrayCb(k)*255), round(arrayCr(k)*255)) + 1;
      else
        pixels_rejected = pixels_rejected + 1;
      end
     
  end
  disp(pixels_rejected)
  disp(pixels)
  prob_image = prob_image./max(prob_image(:));
  figure;
  
  
end




end
