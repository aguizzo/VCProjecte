close all; clc

f=dir('*.jpg');
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
for k=1:15
    im = im_or{k};
    
    gray1 = rgb2gray(im);
    
    ee = strel('disk', 1);
    closeim = imclose(gray1, ee);

    imwawa = edge(gray1, 'roberts');
    imwawa = imfill(imwawa,"holes");
    
    res = imsubtract(closeim, gray1);
    
    %treshold =
    bi = imbinarize(res);
    bi2 = imfill(bi, "holes");
    
    ee = strel('rectangle', [20,100]);
    rectangulos = imopen(bi2, ee);
    
    ee = strel('rectangle', [15,3]);
    palitos = imopen(bi2, ee);
    
    rec = imreconstruct(palitos,rectangulos);
    rec = imreconstruct(bi2,rec);
    
    im2 = im;
    im2(:,:,3) = im2(:,:,3) .* uint8(~rec);
    im2(:,:,2) = im2(:,:,2) .* uint8(~rec);
    im2(:,:,1) = im2(:,:,1) + uint8(rec)*256;
    im_res{k} = im2;
    %im_res{k} = imwawa;
end

%figure, imshow(im), title("Imatge Original");
%figure, imshow(gray1), title("Passem a escala de grisos");
%figure, imshow(closeim), title("Eliminem estructures negres");
%figure, imshow(res), title("Imatge close top hat");
%figure, imshow(bi), title("Binarització top hat");
%figure, imshow(bi2), title("Omplert forats binarització");
%figure, imshow(rectangulos), title("Detectem rectangles amples i llargs horitzontals");
%figure, imshow(palitos), title("Detectem palets verticals (lletres)");
%figure, imshow(rec), title("Reconstruccions");


%for k=15:numel(im_or)
for k=1:15
    figure, subplot(1,2,1), imshow(im_or{k}), title("Imatge original");
    subplot(1,2,2), imshow(im_res{k}), title("Matricula");
end



