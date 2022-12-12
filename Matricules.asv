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
for k=11:25
    im = im_or{k};
    
    gray1 = rgb2gray(im);

    bi2 = imbinarize(gray1);
    
    ee = strel('disk', 1);
    closeim = imclose(gray1, ee);

    imwawa = edge(gray1, 'roberts');
    %imwawa = imfill(imwawa,"holes");
    
    res = imsubtract(closeim, gray1);
    
    %treshold = ridncalv(im);
    bi = imbinarize(res);
    ee = strel('rectangle', [10,2]);
    res = imclose(bi, ee);
    ee = strel('rectangle', [2,10]);
    res = imclose(res, ee);
    ee = strel('line',10,45);
    res = imclose(res, ee);
    res = imclose(res, transpose(ee));
    res = imfill(res, "holes");

    res = imsubtract(res,bi);
    res = imfill(res, "holes");
    
    ee = strel('rectangle', [20,90]);
    rectangulos = imopen(bi2, ee);
    
    ee = strel('rectangle', [15,3]);
    palitos = imopen(bi2, ee);
    
    rec = imreconstruct(palitos,rectangulos);
    rec = imreconstruct(res,(double(rec)));
    
    im2 = im;
    im2(:,:,3) = im2(:,:,3) .* uint8(~rec);
    im2(:,:,2) = im2(:,:,2) .* uint8(~rec);
    im2(:,:,1) = im2(:,:,1) + uint8(rec)*256;
    im_res{k} = rec;
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
for k=11:25
    figure, subplot(1,2,1), imshow(im_or{k}), title("Imatge original");
    subplot(1,2,2), imshow(im_res{k}), title("Matricula");
end



