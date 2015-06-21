clc;  % clc clears all input and output from the Command Window display, giving you a "clean screen."
clear all;  %  removes all variables from the current workspace, releasing them from system memory.
close all;  % deletes the current figure or the specified figure(s). It optionally returns the status of the close operation.
%%

delete(imaqfind)  % imaqfind: Find image acquisition objects
% returns an array containing all the video input objects that exist in memory. 
% If only a single video input object exists in memory, imaqfind displays a detailed summary of that object.
% Nest a call to the imaqfind function within the delete function to delete all these objects from memory.

vid=videoinput('winvideo',1);  % OS Generic Video Interface
% creates a video input object for a webcam image acquisition device. 
% MATLAB files to use Windows Video, Macintosh Video, or Linux Video cameras with the toolbox.
% The correct OS files will be installed, depending on your system.
% Kinect for Windows (kinect)
% Linux Video (linuxvideo)

triggerconfig(vid,'manual');
% Configure video input object trigger properties.
% configures the value of the TriggerType property of the video input object "vid"
% to the value specified by the text string type that here is "manual". 
% TriggerType Value are immediate,manual,hardware.
% immediate: The trigger occurs automatically, immediately after the start function is issued. This is the default trigger type.
% manual: The trigger occurs when you issue the trigger function. A manual trigger can provide more control over image acquisition. 
% For example, you can monitor the video stream being acquired, using the preview function, 
% and manually execute the trigger when you observe a particular condition in the scene.
% hardware: Hardware triggers are external signals that are processed directly by the hardware.


set(vid,'FramesPerTrigger',1 );  % The default is 10 frames per trigger
set(vid,'TriggerRepeat', Inf);
% Specify number of additional times trigger executes
% If TriggerRepeat is set to its default value of zero, then the trigger executes once.
% If TriggerRepeat is set to inf then the trigger executes continuously until a stop function is issued or an error occurs.

% start(vid);

%  View the default color space used for the data — The value of the ReturnedColorSpace property indicates the color space of the image data.
color_spec=vid.ReturnedColorSpace;
% specifies the color space you want the toolbox to use when it returns image data to the MATLAB workspace. 
% grayscale,rgb,YCbCr

% Modify the color space used for the data — 
% To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
if  ~strcmp(color_spec,'rgb')
    set(vid,'ReturnedColorSpace','rgb');
end

start(vid)  % to start the image acquisition object.


% Create a detector object
faceDetector = vision.CascadeObjectDetector;   
faceDetectorLeye = vision.CascadeObjectDetector('EyePairBig'); 
faceDetectorM = vision.CascadeObjectDetector('Mouth'); 
load ix
for ii = 1:100
    trigger(vid);  % as we are calling it manually
    im=getdata(vid,1); % Get the frame in im
    imshow(im)  % Display image
    
    subplot(3,4,[1 2 5 6 9 10]);  % Create and control multiple axes
    % subplot('Position',[left bottom width height])
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
        
        imwrite(Leye,['Database/LE/' num2str(ix) '.bmp']);
        imwrite(Reye,['Database/RE/' num2str(ix) '.bmp']);
        imwrite(Emouth,['Database/M/' num2str(ix) '.bmp']);
       ix  = ix+1;
       save ix ix
        pause(0.00005)
    end
end

