clc;
clear all;
close all;
%%
cl = {'open','close'};

% Initialise empty cell structure
DBL = cell(1,1);
DBR = cell(1,1);
DBM = cell(1,1);

dim = [30 60;
        30 60
        40 65];
% Left eye
disp('Training left eye');
for ii = 1:2
    disp(cl{ii})
    fpath = ['Database/LE/' cl{ii} '/*.bmp'];
    D = dir(fpath);
    for kk = 1:length(D)
        impath = ['Database/LE/' cl{ii} '/' D(kk).name];
        
        I = imread(impath);
        
        % Resize to standard size
        Is = imresize(I,[dim(1,1) dim(1,2)]);
%         [nr nc] = size(I);

        % Save to database
        DBL{ii,kk} = Is;
        imshow(Is);
        pause(0.01)
    end
end

% Right Eye
disp('Training Right eye');
for ii = 1:2
    disp(cl{ii})
    fpath = ['Database/RE/' cl{ii} '/*.bmp'];
    D = dir(fpath);
    for kk = 1:length(D)
        impath = ['Database/RE/' cl{ii} '/' D(kk).name];
        
        I = imread(impath);
        
        % Resize to standard size
        Is = imresize(I,[dim(2,1) dim(2,2)]);
%         [nr nc] = size(I);

        % Save to database
        DBR{ii,kk} = Is;
        imshow(Is);
        pause(0.01)
    end
end

% Mouth
disp('Training Mouth');
for ii = 1:2
    disp(cl{ii})
    fpath = ['Database/M/' cl{ii} '/*.bmp'];
    D = dir(fpath);
    for kk = 1:length(D)
        impath = ['Database/M/' cl{ii} '/' D(kk).name];
        
        I = imread(impath);
        
        % Resize to standard size
        Is = imresize(I,[dim(3,1) dim(3,2)]);
     
        % Save to database
        DBM{ii,kk} = Is;
        imshow(Is);
        pause(0.01)
    end
end

% Save the database
save DB DBL DBR DBM
