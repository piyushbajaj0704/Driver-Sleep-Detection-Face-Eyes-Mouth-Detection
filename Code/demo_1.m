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


% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
set(vid,'ReturnedColorSpace','rgb');

start(vid)


% Create a detector object
faceDetector = vision.CascadeObjectDetector;   
faceDetectorLeye = vision.CascadeObjectDetector('EyePairBig'); 
faceDetectorM = vision.CascadeObjectDetector('Mouth'); 

for ii = 1:500
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

         S = skin_seg2(im);
    
        % Segment skin region
        bw3 = cat(3,S,S,S);

        % Multiply with original image and show the output
        Iss = double(im).*bw3;

        Ic = imcrop(im,bbox);
        Ic1 = imcrop(Iss,bbox);
        subplot(3,4,[3 4]);
        imshow(uint8(Ic1))
        
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
            end
        else
            disp('Mouth not detected')
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
        
        % Moth
        % Resize to standard size
        Emouth =  imresize(Emouth,[dim(3,1) dim(3,2)]);
        c3 = match_DB(Emouth,DBM);
        subplot(3,4,[11,12]);
        title(cl{c3})

        pause(0.00005)
    end
end

