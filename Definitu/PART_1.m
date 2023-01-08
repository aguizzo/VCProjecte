%% Detecció de Matrícules
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

%% Detecció de Potencials Matrícules
% <include>F_PotencialsMatricules.m</include>

%% Eliminat de no-matricules
% <include>F_EliminarNoMatricules.m</include>

%% Binaritzat Riddler i Calvard
% <include>ridncalv.m</include>

%% RESULTATS
% En vermell i verd es troben remarcades les matrícules detectades en la
% primera funció. En verd hem ressaltat els candidats que han sobreviscut a la segona
% funció

im_mat=cell(1,numcotxes);
for k=1:numcotxes
    im_mat{k}=F_PotencialsMatricules(im_ors{k});
end

im_mat2=cell(1,numcotxes);
for k=1:numcotxes
    im_mat2{k}=F_EliminarNoMatricules(im_ors{k},im_mat{k});
end

for k=1:numcotxes
    imres = im_ors{k};

    immat2 = imdilate(im_mat{k},strel("disk",5)) - im_mat{k};
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat2);
    imres(:,:,2) = imres(:,:,2) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) + uint8(immat2)*256;

    immat2 = imdilate(im_mat2{k},strel("disk",5)) - im_mat2{k};
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) .* uint8(~immat2);
    imres(:,:,2) = imres(:,:,2) + uint8(immat2)*256;

    figure, imshow(imres), title(names(k));
end