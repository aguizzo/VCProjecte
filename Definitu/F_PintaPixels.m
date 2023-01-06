function res = F_PintaPixels(imor,pixelList,val)
    res = imor;
    for row = 1 : size(pixelList(:, 2))
    thisRow = pixelList(row, 2);
    thisColumn = pixelList(row, 1);
    res(thisRow, thisColumn) = val;
    end
end