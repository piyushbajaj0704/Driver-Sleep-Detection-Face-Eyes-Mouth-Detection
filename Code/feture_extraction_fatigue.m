clc;
clear all;
close all;
%%
load DB
cl = {'open','close'};

dim = [30 60;
        30 60
        40 65];
delete(imaqfind)
vid=videoinput('winvideo',1);
triggerconfig(vid,'manual');
set(vid,'FramesPerTrigger',1 );
set(vid,'TriggerRepeat', Inf);
% start(vid);

%  View the default color space used for the data — The value of the ReturnedColorSpace property indicates the color space of the image data.
color_spec=vid.ReturnedColorSpace;

% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
if  ~strcmp(color_spec,'rgb')
    set(vid,'ReturnedColorSpace','rgb');
end

start(vid)


% Create a detector object
faceDetector = vision.CascadeObjectDetector;   
faceDetectorLeye = vision.CascadeObjectDetector('EyePairBig'); 
faceDetectorM = vision.CascadeObjectDetector('Mouth'); 
tic
% Initialise vector
LC = 0; % Left eye closer
RC = 0; % Right eye closer
MC = 0; % Mouth closer
TF = 0; % Total frames
TC = 0; % Total closure
Feature = [];
c1p = 1;
for ii = 1:100
   
    trigger(vid);
    im=getdata(vid,1); % Get the frame in im
    imshow(im)
    
    subplot(3,4,[1 2 5 6 9 10]);
    imshow(im)
    
    % Detect faces
    bbox = step(faceDetector, im); 
    
    if ~isempty(bbox);
        bbox = bbox(1,:);

        % Plot box
        rectangle('Position',bbox,'edgecolor','r');

        Ic = imcrop(im,bbox);
        subplot(3,4,[3 4]);
        imshow(Ic)
        
        bboxeye = step(faceDetectorLeye, Ic); 
        
        if ~isempty(bboxeye);
            bboxeye = bboxeye(1,:);

            Eeye = imcrop(Ic,bboxeye);
            % Plot box
            rectangle('Position',bboxeye,'edgecolor','y');
        else
            disp('Eyes not detected')
        end
        
        if isempty(bboxeye)
            continue;
        end
       Ic(1:bboxeye(2)+2*bboxeye(4),:,:) = 0; 

        % Detect Mouth
        bboxM = step(faceDetectorM, Ic); 
        

        if ~isempty(bboxM);
            bboxMtemp = bboxM;
            
            if ~isempty(bboxMtemp)
            
                bboxM = bboxMtemp(1,:);
                Emouth =  imcrop(Ic,bboxM);

                % Plot box
                rectangle('Position',bboxM,'edgecolor','y');
            else
                disp('Mouth  not detected')
                continue;
            end
        else
            disp('Mouth not detected')
            continue;
        end
        
        [nre nce k ] = size(Eeye);
        
        % Divide into two parts
        Leye = Eeye(:,1:round(nce/2),:);
        Reye = Eeye(:,round(nce/2+1):end,:);
              
        subplot(3,4,7)
        imshow(Leye);
        subplot(3,4,8)
        imshow(Reye);
        subplot(3,4,[11,12]);
        imshow(Emouth);
        
        Leye = rgb2gray(Leye);
        Reye = rgb2gray(Reye);
        Emouth = rgb2gray(Emouth);

        % Template matching using correlation coefficient
        % Left eye
        % Resize to standard size
        Leye =  imresize(Leye,[dim(1,1) dim(1,2)]);
        c1 =match_DB(Leye,DBL);
        subplot(3,4,7)
        title(cl{c1})
        
        
        % Right eye
        % Resize to standard size
        Reye =  imresize(Reye,[dim(2,1) dim(2,2)]);
        c2 = match_DB(Reye,DBR);
        subplot(3,4,8)
        title(cl{c2})
        
        % Mouth
        % Resize to standard size
        Emouth =  imresize(Emouth,[dim(3,1) dim(3,2)]);
        c3 = match_DB(Emouth,DBM);
        subplot(3,4,[11,12]);
        title(cl{c3})
        
        
        if c1 == 2
            LC = LC+1;
            if c1p == 1
                TC = TC+1;
            end
        end
        if c2==2
            RC = RC+1;
        end
        if c3 == 1
            MC = MC + 1;
        end

        TF = TF + 1; % Total frames
        
        if toc>10
            Feature = [Feature;LC/TF RC/TF MC/TF TC]
            tic
            % Initialise vector
            LC = 0; % Left eye closer
            RC = 0; % Right eye closer
            MC = 0; % Mouth closer
            TF = 0; % Total frames
            TC = 0; % Total closure
        end
        c1p = c1;
        pause(0.00005)
    end
end

save FA Feature 