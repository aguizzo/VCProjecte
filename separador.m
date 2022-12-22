f=dir(['*.png']);
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
    matricula = rgb2gray(im_ors{k});
    figure, imshow(matricula), title(['Matricula ', num2str(k)]);
    etiq = bwlabel(matricula);
    objects = regionprops('table', etiq, 'BoundingBox');
    rectangles = table2array(objects);
    imRectangles = insertShape(matricula, 'Rectangle', table2array(objects), 'LineWidth', 1);
    figure, imshow(imRectangles), title(['Matricula delimitda ', num2str(k)]);
    nRectangles = size(rectangles);
    for i = 2:nRectangles(1)
        xmin = ceil(rectangles(i,1));
        ymin = ceil(rectangles(i,2));
        xmax =  rectangles(i,3) + xmin;
        ymax = rectangles(i,4) + ymin;
        area = (xmax-xmin) * (ymax - ymin);
    
        if (area > 80)
            Image=etiq((ymin-2):(ymax+2),(xmin-2):(xmax+2));
            figure,imshow(Image), title(['Regio ', num2str(i)]);
        end
    end
end