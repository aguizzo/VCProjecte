close all; clc

f=dir(['cars' '/*.jpg']);
files={f.name};
names = convertCharsToStrings(files);
for k=1:numel(names)
    names(k) = erase(names(k),".jpg");
end
im_ors=cell(1,numel(names));
for k=1:numel(files)
  im_ors{k}=imread(files{k});
end

for k=1:numel(im_ors)
    % Imatge Original
    imor = im_ors{k};

    % Passem a escala de grisos i eliminem els píxels amb molt de color
    imgray = rgb2gray(imor);

    % Passem a Blanc i negre i obtenim edges
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

    %figure, imshow(imor);
    for i=1:count
       boundingBox=Iprops(i).BoundingBox;
       region = imcrop(imgray,boundingBox+[-2,-2,+4,+4]);
    
       ridncalv = @ridncalv;
       regbin = ~imbinarize(region,ridncalv(region));
       
       % Eliminem les regions amb < 6 regions connexes,
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

       % Eliminem les regions amb proporcions inadequades
       [n, m] = size(regbin);
       ratio = abs(n/m - 110/520)*100;
       
       if cc.NumObjects > 5 && ratio < 35

           % Eliminem els elements molt grans
           reggran = imopen(regbin,strel("rectangle",[9,9]));
           reglletres =  logical(regbin - reggran);
    
           % Eliminem els elements molt llargs
           reggran = imopen(reglletres,strel("rectangle",[1,30]));
           reglletres =  logical(reglletres - reggran);

           % Unim lletres separades
           reglletres = imclose(reglletres,strel("rectangle",[2,1]));

           % Eliminem els elements molt fins
           reglletres = imopen(reglletres,strel("rectangle",[2,1]));

           lletresProps=regionprops(reglletres,'BoundingBox','Area', 'Image','PixelList');
           
           for ii=1:numel(lletresProps)
                if lletresProps(ii).Area < 10
                    cum(lletresProps(ii).PixelList(1,:)) = 1;
                end
           end
    
       end

    end 
    
    %figure,imshow(imbinarize(imgraymat));

    imres = imor;
    imres(:,:,3) = imres(:,:,3) .* uint8(~immat);
    imres(:,:,2) = imres(:,:,2) .* uint8(~immat);
    imres(:,:,1) = imres(:,:,1) + uint8(immat)*256;
    
end
