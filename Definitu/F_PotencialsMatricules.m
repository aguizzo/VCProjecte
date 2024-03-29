% Aquesta funció detecta aquelles regions de la imatge que són potencials
% matrícules

function immat = F_PotencialsMatricules(imor)

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

    % Eliminem els bordes de les zones massa grans
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
end