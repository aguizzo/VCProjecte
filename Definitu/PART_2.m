%% Detecció de Caràcters
%% CODI
%% Imatges Inicials
close all; clc
w = warning ('off','all');

f=dir(['cars' '/*.jpg']);
files={f.name};
numcotxes = numel(files);
names = convertCharsToStrings(files);
for k=1:numcotxes
    names(k) = erase(names(k),".jpg");
    names(k) = erase(names(k),".JPG");
    names(k) = erase(names(k),"_");
end

im_ors=cell(1,numcotxes);
for k=1:numcotxes
  im_ors{k}=imread(files{k});
end

im_mat=cell(1,numcotxes);
for k=1:numcotxes
    im_mat{k}=F_PotencialsMatricules(im_ors{k});
end

im_mat2=cell(1,numcotxes);
for k=1:numcotxes
    im_mat2{k}=F_EliminarNoMatricules(im_ors{k},im_mat{k});
end

%% Selecció de Caràcters
% <include>F_SeleccionarNumeros.m</include>

%% Pintat de Píxels
% <include>F_PintaPixels.m</include>

%% RESULTATS

im_nums=cell(1,numcotxes);
for k=1:numcotxes
    im_nums{k}=F_SeleccionarNumeros(im_ors{k},im_mat2{k});
end

for k=1:numcotxes
    imres = im_ors{k};
    immat2 = imdilate(im_nums{k},strel("disk",5)) - im_nums{k};
    imres(:,:,2) = imres(:,:,2) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) .* uint8(~immat2);
    imres(:,:,3) = imres(:,:,3) + uint8(immat2)*256;
    
    figure, imshow(imres), title(names(k));
    figure, imshow(im_nums{k});
end