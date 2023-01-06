close all; clc

f=dir(['*.jpg']);
files={f.name};
names = convertCharsToStrings(files);
for k=1:numel(names)
    names(k) = erase(names(k),".jpg");
end
im_ors=cell(1,numel(names));
for k=1:numel(files)
  im_ors{k}=imread(files{k});
end

chars_or = imread("chars\Greek-License-Plate-Font-2004-2.jpg");
chars = rgb2gray(chars_or);
chars = imbinarize(chars);
charsPoints=detectSIFTFeatures(chars, Sigma=1.0, EdgeThreshold=15.0, ContrastThreshold=0.0115);
figure, imshow(chars)
title('Characters');
hold on;
plot(selectStrongest(charsPoints, 200));

[charsFeat, charsPoints] = extractHOGFeatures(chars, charsPoints);


% 41-46, 59
%for k=15:numel(im_or)
for k=1:numel(im_ors)
    % Imatge Original
    imor = im_ors{k};

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

    % Subdividim les zones massa grans
    ee = strel('rectangle',[200,200]);
    imgrans = imopen(immat,ee);
    imgrans = imreconstruct(imgrans,immat);
    imgransbordes = imdilate(imgrans,strel('disk',10));
    imgransbordes = imgransbordes - imgrans;
    imedges = logical(imedges - (imedges .* imgransbordes));

    % Repetim selecció de zones tancades
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

    % Eliminem els blobs en contacte amb els bordes
    [n, m] = size(imbin);
    imbordes = logical(zeros(n,m));
    imbordes(1:3,:) = 1;
    imbordes(n-2:n,:) = 1;
    imbordes(:,1:3) = 1;
    imbordes(:,m-2:m) = 1;
    imtouching = imreconstruct(imbordes,immat);

    immat = logical(immat - imtouching);

    % Emmarcat de Carácters
    Iprops=regionprops(immat,'BoundingBox','Area', 'Image');
    count = numel(Iprops);

    figure, imshow(imor);

    MATRICULES = cell(1,200);
    index = 1;

    for i=1:count
       boundingBox=Iprops(i).BoundingBox;
       region = imcrop(imgray,boundingBox+[-2,-2,+4,+4]);
    
       ridncalv = @ridncalv;
       regbin = ~imbinarize(region,ridncalv(region));
       
       % Eliminem les regions amb < 4 regions connexes,
       % després de filtrar estructures petites
       ee = strel("rectangle",[7,1]);
       regero = imerode(regbin,ee);
       regrec2 = imreconstruct(regero,regbin);

       ee = strel("rectangle",[1,2]);
       regero = imerode(regrec2,ee);
       regrec2 = imreconstruct(regero,regrec2);

       regrec2 = imclose(regrec2,strel("rectangle",[2,1]));

       regrec2 = padarray(regrec2,[1,1],1);
       cc = bwconncomp(regrec2);
       
       regSize = size(regrec2);

       if (cc.NumObjects > 5 && regSize(2) > 115)
            %figure, imshow(regbin);
            %matricula = double(regrec2);
            matricula = double(regbin);
            figure, imshow(matricula), title(['Matricula ', num2str(k)]);
            matricula = padarray(matricula,[5 5],0,'both');
            etiq = bwlabel(matricula);
            objects = regionprops('table', etiq, 'BoundingBox');
            rectangles = table2array(objects);
            imRectangles = insertShape(matricula, 'Rectangle', table2array(objects), 'LineWidth', 1);
            figure, imshow(imRectangles), title(['Matricula delimitda ', num2str(k)]);
            nRectangles = size(rectangles);
            for j = 2:nRectangles(1)
                xmin = ceil(rectangles(j,1));
                ymin = ceil(rectangles(j,2));
                xmax =  rectangles(j,3) + xmin;
                ymax = rectangles(j,4) + ymin;
                area = (xmax-xmin) * (ymax - ymin);
            
                if (area > 80)
                    Image =etiq((ymin-2):(ymax+2),(xmin-2):(xmax+2));
                    %figure,imshow(Image), title(['Regio ', num2str(j)]);
                    Image = imbinarize(Image);
                    Image = padarray(Image,[10 10],0,'both');
                    platePoints=detectSIFTFeatures(Image, Sigma=0.8);
                    figure, imshow(Image)
                    title(['KP Regio ', num2str(j)]);
                    hold on;
                    plot(selectStrongest(platePoints, 100));
                    [plateFeat, platePoints] = extractHOGFeatures(Image, platePoints);
                    
                    pairs = matchFeatures(plateFeat, charsFeat, 'MatchThreshold', 20, MaxRatio=0.75);
                    m_kp_plate = platePoints(pairs(:,1), :);
                    m_kp_char = charsPoints(pairs(:,2), :);
                    
                    figure;
                    showMatchedFeatures(Image, chars, m_kp_plate, m_kp_char, 'montage');
                    title('Aparellaments putatius');        
                end
            end
        end
    end   
end
