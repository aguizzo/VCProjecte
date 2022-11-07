close all; clc

f=dir('*.jpg');
files={f.name};
names = convertCharsToStrings(files);
for k=1:numel(names)
    names(k) = erase(names(k),".jpg");
end
im_or=cell(1,3);
for k=1:numel(files)
  im_or{k}=imread(files{k});
end

for k=1:numel(im_or)
    im = im_or{k};
    
    gray1 = rgb2gray(im);
    
    ee = strel('rectangle', [5,10]);
    closeim = imclose(gray1, ee);
    
    res = imsubtract(closeim, gray1);
    
    bi = imbinarize(res);
    bi2 = imfill(bi, "holes");
    
    ee = strel('rectangle', [20,100]);
    rectangulos = imopen(bi2, ee);
    
    ee = strel('rectangle', [15,3]);
    palitos = imopen(bi, ee);
    
    rec = imreconstruct(palitos,rectangulos);
    rec = imreconstruct(bi2,rec);
    
    im2 = im;
    im2(:,:,3) = im2(:,:,3) .* uint8(~rec);
    im2(:,:,2) = im2(:,:,2) .* uint8(~rec);
    im2(:,:,1) = im2(:,:,1) + uint8(rec)*256;
    im_res{k} = im2;
end

figure, imshow(im), title("Imatge Original");
figure, imshow(gray1), title("Passem a escala de grisos");
figure, imshow(closeim), title("Eliminem estructures negres");
figure, imshow(res), title("Imatge close top hat");
figure, imshow(bi), title("Binarització top hat");
figure, imshow(bi2), title("Omplert forats binarització");
figure, imshow(rectangulos), title("Detectem rectangles amples i llargs horitzontals");
figure, imshow(palitos), title("Detectem palets verticals (lletres)");
figure, imshow(rec), title("Reconstruccions");


figure, subplot(1,2,1), imshow(im_or{1}), title("Imatge original");
subplot(1,2,2), imshow(im_res{1}), title("Matricula");

figure, subplot(1,2,1), imshow(im_or{2}), title("Imatge original");
subplot(1,2,2), imshow(im_res{2}), title("Matricula");

figure, subplot(1,2,1), imshow(im_or{3}), title("Imatge original");
subplot(1,2,2), imshow(im_res{3}), title("Matricula");




