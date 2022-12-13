% Calcul del llindar amb el coeficient anisotropic de Pun
function treshold = pun(im)
    %im = im .* uint8(fons(im));
    [histogram, ~] = imhist(im);
    %histogram(1) = 0;
    percentages = histogram/sum(histogram);
    acumulated = 0;
    initialTreshold = 1;
    % El llindar inicial serà aquell contingui con a mínim la meitat dels
    % pixels de la imatge.
    while acumulated < 0.5 && initialTreshold < 256
        acumulated = acumulated + percentages(initialTreshold);
        initialTreshold = initialTreshold + 1;
    end
    % Càlcul del coefiecient anisotropic
    div = 0;
    % Afegim un petit número per evitar infinits en els logaritmes
    epsilon = 0.000001;
    for i = 1:size(percentages)
        if(percentages(i) ~= 0)
            div = div + percentages(i) * log2(percentages(i));
        else
            div=div+(epsilon+percentages(i))*log2(percentages(i)+epsilon);
        end
    end
    num = 0;
    for i = 1:initialTreshold
        if(percentages(i) ~= 0)
            num = num + percentages(i) * log2(percentages(i));
        else 
            num=num+(epsilon+percentages(i))*log2(percentages(i)+epsilon);
        end
    end
    treshold = num / div;
    if treshold <= 0.5
        treshold = 1 - treshold;
    end
end