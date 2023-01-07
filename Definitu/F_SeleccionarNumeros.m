% Seleccionem els números dels components connexos de les matrícules

function imnums = F_SeleccionarNumeros(imor,immat)
    [n, m] = size(immat);
    imnums = logical(zeros(n,m));
    
    Iprops=regionprops(immat,'BoundingBox','Area', 'Image');
    count = numel(Iprops);

     for i=1:count
        if Iprops(i).Area < 1000
            continue
        end
        boundingBox=Iprops(i).BoundingBox;
        regionCol = imcrop(imor,boundingBox);
        region = rgb2gray(regionCol);

        ridncalv = @ridncalv;
        regbin = ~imbinarize(region,ridncalv(region));

        regionmat = imcrop(immat,boundingBox);
        regbin = regionmat.*regbin;

        % Eliminem els elements molt grans
        reggran = imopen(regbin,strel("rectangle",[9,9]));
        reglletres =  logical(regbin - reggran);
    
        % Eliminem els elements molt llargs
        reggran = imopen(reglletres,strel("rectangle",[1,30]));
        reglletres =  logical(reglletres - reggran);

        %Eliminem les zones de colors(marcadors de pais)
        imhsv = rgb2hsv(regionCol);
        imcol = imhsv(:,:,2) .* imhsv(:,:,3);
        imcol = imbinarize(imcol,0.3);
        reglletres = reglletres .* (~imcol);
        reglletres = logical(reglletres);

        %Filtrem els components connexos molt estrets
        imer = imerode(reglletres, strel("rectangle",[5,1]));
        reglletres = imreconstruct(imer,reglletres);

        % Unim lletres separades
        reglletres = imclose(reglletres,strel("rectangle",[4,1]));

        % Eliminem els components connexos molt petits
        reglletres = bwareafilt(reglletres,[15,100000]);
        
        % Treballem amb les regions
        [n2,m2] = size(reglletres);
        props=regionprops(bwconncomp(reglletres),'BoundingBox','PixelList','Solidity','Circularity','Image');
        for j=1:numel(props)
            prop = props(j);
            pl = prop.PixelList;
            X = ceil(prop.BoundingBox(1)); Y = ceil(prop.BoundingBox(2));
            W = prop.BoundingBox(3); H = prop.BoundingBox(4);
            
            % Eliminem elements poc sòlids
            if prop.Solidity < 0.3
                reglletres = F_PintaPixels(reglletres,pl,0);
                continue;
            end

            % Eliminem els elements massa llargs
            if W > m2*0.4
                reglletres = F_PintaPixels(reglletres,pl,0);
                continue;
            end

            % Eliminem els elements massa circulars
            if prop.Circularity > 0.5 && W/H > 0.9
                reglletres = F_PintaPixels(reglletres,pl,0);
                continue;
            end
    
            % Eliminem els elements massa poc llargs
            if H < n2/6 || H < 10 || W < 2
                reglletres = F_PintaPixels(reglletres,pl,0);
                continue;
            end

            % Dividim els elements que no encaixen la proporció
            ratio = 0.9;
            if W/H > ratio && numel(props) < 8
                reglletres(Y:Y+H,X+ceil(W/2)) = 0;
            end
        
            X = boundingBox(1); Y = boundingBox(2);
            W = boundingBox(3); H = boundingBox(4);
            imnums(Y:Y+H, X:X+W) = reglletres;  
        end    
     end

     % Eliminem els components connexos aïllats
     regunits = imclose(imnums, strel("rectangle",[1,30]));
     regnoaillats = imerode(regunits,strel("rectangle",[1,50]));
     regnoaillats = imreconstruct(regnoaillats,regunits);
     imnums = regnoaillats .* imnums;
       
     Iprops=regionprops(bwconncomp(imnums),'BoundingBox','PixelList');
     count = numel(Iprops);
     nums_data = zeros(0,3);
     for i=1:count
         prop = Iprops(i);
         pl = prop.PixelList;
         X = ceil(prop.BoundingBox(1)); Y = ceil(prop.BoundingBox(2));
         W = prop.BoundingBox(3); H = prop.BoundingBox(4);

         % Eliminem els elements massa llargs
         if W > 50
            imnums = F_PintaPixels(imnums,pl,0);
            continue;
         end

         nums_data(end+1,:) = [H+Y/2,X,i];
     end

     % Escollim els 7 possibles números amb menor diferència d'altura.
     nums_data = sortrows(nums_data);

     if (numel(nums_data(:,1)) > 7)
         min_dist = intmax;
         min_idx = intmax;

         for i=1:numel(nums_data(:,1))-6
             dist = 0;
             for j=1:6
                dist = dist + (nums_data(i+j,1) - nums_data(i,1));
             end
             if dist < min_dist
                 min_idx = i;
                 min_dist = dist;
             end
         end

         for i=1:numel(nums_data(:,1))
             if i < min_idx || i > min_idx+6
               pl = Iprops(nums_data(i,3)).PixelList;
               imnums = F_PintaPixels(imnums,pl,0);  
             end
         end
         nums_data = nums_data(min_idx:min_idx+6);
     end
end