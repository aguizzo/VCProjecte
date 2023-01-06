close all; clc

f=dir(['cars' '/*.jpg']);
files={f.name};
numcotxes = numel(files);
names = convertCharsToStrings(files);
for k=1:numcotxes
    names(k) = erase(names(k),".jpg");
end
im_ors=cell(1,numcotxes);
for k=1:numcotxes
  im_ors{k}=imread(files{k});
end

for k=1:numcotxes
    imor = im_ors{k};

    imgray = rgb2gray(imor);

    imhsv = rgb2hsv(imor);
    imcol = imhsv(:,:,2) .* imhsv(:,:,3);

    imcol = uint8(imcol*256);

    figure, imshow(imgray-imcol);
end