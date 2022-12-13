%Mètode iteratiu de Riddler i Calvard 
function treshold = ridncalv(im)
    % El llindar inicial és la mitjana de valors de grisos
    currentT = mean(im(:));
    upT = im(im > currentT);
    belowT = im(im <= currentT);  
    umean = sum(upT)/size(upT,1);
    bmean = sum(belowT)/size(belowT,1);
    % El llindar posterior és la mitjana de la suma dels valors que estan
    % per sobre del llindar inicial i de la suma dels valors que estan per
    % sota de llindar inicial
    nextT = (umean+bmean)/2;
    maxIter = 1000;
    i = 1;
    error = 0.0001;
    % Iterem fins obtenir llindar que compleixi amb el marge de error
    while (abs(nextT - currentT) > error) && (i < maxIter)
        currentT = nextT;
        upT = im(im > currentT);
        belowT = im(im <= currentT);  
        umean = sum(upT)/size(upT,1);
        bmean = sum(belowT)/size(belowT,1);
        nextT = (umean+bmean)/2;
        i = i + 1;
    end
    treshold = currentT/256;

end