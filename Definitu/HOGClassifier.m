%% Training Data
lettersTrainingSet = imageDatastore("datasets\training1\letters\" ,'IncludeSubfolders',true,'LabelSource','foldernames');
%countEachLabel(lettersTrainingSet);
numbersTrainingSet = imageDatastore("datasets\training1\numbers\" ,'IncludeSubfolders',true,'LabelSource','foldernames');

%% Test Data
lettersTestSet = imageDatastore("datasets\test1\letters\" ,'IncludeSubfolders',true,'LabelSource','foldernames');
numbersTestSet = imageDatastore("datasets\test1\numbers\" ,'IncludeSubfolders',true,'LabelSource','foldernames');

%% 
img = readimage(lettersTrainingSet, 100);
img = im2gray(img);
img = imbinarize(img);
img = imresize(img,[40 20]);

% Extract HOG features and HOG visualization
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[2 2]);
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);

% Show the original image
figure; 
subplot(2,3,1:3); imshow(img);

% Visualize the HOG features
subplot(2,3,4);  
plot(vis2x2); 
title({'CellSize = [2 2]'; ['Length = ' num2str(length(hog_2x2))]});

subplot(2,3,5);
plot(vis4x4); 
title({'CellSize = [4 4]'; ['Length = ' num2str(length(hog_4x4))]});

subplot(2,3,6);
plot(vis8x8); 
title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});

cellSize = [2 2];
hogFeatureSize = length(hog_2x2);
%% Trainining Features

[letterTrainingFeatures, letterTrainingLabels] = helperExtractHOGFeaturesFromImageSet(lettersTrainingSet, hogFeatureSize, cellSize);
[numbersTrainingFeatures, numbersTrainingLabels] = helperExtractHOGFeaturesFromImageSet(numbersTrainingSet, hogFeatureSize, cellSize);

%% Test Features

[letterTestFeatures, letterTestLabels] = helperExtractHOGFeaturesFromImageSet(lettersTrainingSet, hogFeatureSize, cellSize);
[numbersTestFeatures, numbersTestLabels] = helperExtractHOGFeaturesFromImageSet(numbersTrainingSet, hogFeatureSize, cellSize);
