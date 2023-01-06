% Eliminem moltes matricules fals positives que hem detectat
% en el pas anterior

function immat = F_EliminarNoMatricules(imor,immator)
    [n, m] = size(immator);
    immat = logical(zeros(n,m));
    
    Iprops=regionprops(immator,'BoundingBox','Area', 'Image');
    count = numel(Iprops);

     for i=1:count
        boundingBox=Iprops(i).BoundingBox;
        region = imcrop(rgb2gray(imor),boundingBox);

        ridncalv = @ridncalv;
        regbin = ~imbinarize(region,ridncalv(region));

        regionmat = imcrop(immator,boundingBox);
        regbin = regionmat.*regbin;

        % Eliminem les regions amb < 5 regions connexes,
        % després de filtrar estructures petites
        ee = strel("rectangle",[7,1]);
        regero = imerode(regbin,ee);
        regrec2 = imreconstruct(regero,regbin);

        ee = strel("rectangle",[1,2]);
        regero = imerode(regrec2,ee);
        regrec2 = imreconstruct(regero,regrec2);

        regrec2 = imclose(regrec2,strel("rectangle",[2,1]));
        regrec2 = imclose(regrec2,strel("rectangle",[1,2]));

        regrec2 = padarray(regrec2,[1,1],1);
        cc = bwconncomp(regrec2);

        % Eliminem les regions amb proporcions inadequades
        [n2, m2] = size(regbin);
        ratio = abs(n2/m2 - 110/520)*100;

        %figure, imshow(regrec2),title(["cc", cc.NumObjects, "ratio", ratio]);
   
        % Afegim la potencial matricula
        if cc.NumObjects > 4 && ratio < 35
            X = boundingBox(1); Y = boundingBox(2);
            W = boundingBox(3); H = boundingBox(4);
            immat(Y:Y+H, X:X+W) = regionmat;
        end
        
     end
end