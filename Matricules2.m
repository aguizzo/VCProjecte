close all; clc

f=dir(['cars' '/*.jpg']);
files={f.name};
names = convertCharsToStrings(files);
for k=1:numel(names)
    names(k) = erase(names(k),".jpg");
end
im_or=cell(1,numel(names));
for k=1:numel(files)
  im_or{k}=imread(files{k});
end

%for k=15:numel(im_or)
for k=1:numel(im_or)
    % Imatge Original
    imor = im_or{k};

    % Passem a Blanc i negre i obtenim edges
    imgray = rgb2gray(imor);
    imbin = imbinarize(imgray);
    imedges = edge(imgray, 'prewitt');
    imedges(200,:) = 0;

    % Seleccionem les zones tancades
    ee = strel('rectangle',[5,10]);
    immat = imdilate(imedges,ee);
    immat = imfill(immat,"holes");
    ee = strel('line',20,0);
    immat = imerode(immat,ee);
    ee = strel('line',10,90);
    immat = imerode(immat,ee);

    % Eliminem les línies verticals o horitzontals molt finetes
    immat = imopen(immat,strel("rectangle",[15,1]));
    immat = imopen(immat,strel("rectangle",[1,15]));
    
    % Separem blobs propers
    td = bwdist(~immat);
    td = imhmax(td,4);
    segm = watershed(-td);
    immat = ~(~immat | (segm == 0));

    % Eliminem les zones no rectangulars
    ee = strel('rectangle',[15,50]);
    imnorectangles = imopen(immat,ee);
    imnorectangles = imreconstruct(imnorectangles,immat);

    immat = logical(immat .* imnorectangles);

    % Eliminem les zones sense línies verticals o horitzontals
    ee = strel('rectangle',[5,1]);
    imlines_v = imopen(imedges,ee);
    imlines = imreconstruct(imlines_v,immat);
    ee = strel('rectangle',[1,5]);
    imlines_h = imopen(imedges,ee);
    imlines = imreconstruct(imlines_h,imlines);

    immat = logical(immat .* imlines);

    % Eliminem les zones massa grans
    ee = strel('rectangle',[100,100]);
    imgrans = imopen(immat,ee);
    imgrans = imreconstruct(imgrans,immat);
    immat = logical(immat .* (~imgrans));

    imres = imor;
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat);
    imres(:,:,2) = imres(:,:,2) .* uint8(~immat);
    imres(:,:,1) = imres(:,:,1) + uint8(immat)*256;

    figure, imshow(imres);

end