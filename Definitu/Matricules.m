%% Projecte VC: Detecció de Matrícules.
%% Imatges Inicials
close all; clc
w = warning ('off','all');

%f=dir(['cars' '/*.jpg']);
f=dir('*.jpg');
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


%% Detectem Potencials Matrícules
% <include>F_PotencialsMatricules.m</include>
close all;

im_mat=cell(1,numcotxes);
for k=1:numcotxes
    im_mat{k}=F_PotencialsMatricules(im_ors{k});
end

% Exemples:
for k=1:3
    imres = im_ors{k};
    immat2 = imdilate(im_mat{k},strel("disk",5)) - im_mat{k};
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) .* uint8(~immat2);
    imres(:,:,2) = imres(:,:,2) + uint8(immat2)*256;
    %figure, imshow(imres);
end

%% Eliminem no-matricules
% <include>F_EliminarNoMatricules.m</include>
close all;

im_mat2=cell(1,numcotxes);
for k=1:numcotxes
    im_mat2{k}=F_EliminarNoMatricules(im_ors{k},im_mat{k});
end

% Exemples:
for k=1:3
    imres = im_ors{k};

    immat2 = imdilate(im_mat{k},strel("disk",5)) - im_mat{k};
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat2);
    imres(:,:,2) = imres(:,:,2) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) + uint8(immat2)*256;

    immat2 = imdilate(im_mat2{k},strel("disk",5)) - im_mat2{k};
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) .* uint8(~immat2);
    imres(:,:,2) = imres(:,:,2) + uint8(immat2)*256;

    %figure, imshow(imres);
end

%% Seleccionem Números
% <include>F_SeleccionarNumeros.m</include>
close all;

im_nums=cell(1,numcotxes);
for k=1:numcotxes
    im_nums{k}=F_SeleccionarNumeros(im_ors{k},im_mat2{k});
end

imgNumb = 1;
for k=1:numcotxes
    figure, imshow(im_nums{k}), title(f(k).name);
    ax = gca;
    filename = num2str(imgNumb);
    dir = 'results\';
    filename = strcat(dir, filename);
    filename = strcat(filename, '.jpg');
    exportgraphics(ax,filename) ;
    imgNumb = imgNumb + 1 ;
    Iprops=regionprops(bwconncomp(im_nums{k}),'Image');
     count = numel(Iprops);
     for i=1:count
      imNum = Iprops(i).Image;
      [files, cols] = size(imNum);
      area = files * cols;
      %if (area > 60 && files < 35 && cols < 25)
         imNum = padarray(imNum,[3 3],0,'both');
         figure, imshow(~imNum);
         ax = gca;
         filename = num2str(imgNumb);
         filename = strcat(dir, filename);
         filename = strcat(filename, '.jpg');
         exportgraphics(ax,filename) ;
         imgNumb = imgNumb + 1 ;
      %end
     end 
end

% Exemples:
for k=1:numcotxes
    imres = im_ors{k};
    immat2 = imdilate(im_nums{k},strel("disk",5)) - im_nums{k};
    imres(:,:,2) = imres(:,:,2) .* uint8(~immat2);
    imres(:,:,1) = imres(:,:,1) .* uint8(~immat2);
    imres(:,:,3) = imres(:,:,3) + uint8(immat2)*256;
    %figure, imshow(imres);
end
