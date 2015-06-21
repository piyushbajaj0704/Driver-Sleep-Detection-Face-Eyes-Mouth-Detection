clc;
clear all;
close all;
%%
load FA
F1 = Feature;
load NF
F2 = Feature;
xdata = [F1;F2];
group = cell(1,1);

for ii = 1:size(F1,1)
    group{ii,1} = 'Fatigue';
end

for ii = 1:size(F2,1)
    group{ii+size(F1,1),1} = 'Non-Fatigue';
end

svmStruct = svmtrain(xdata,group,'showplot',true);
% Testing
save svm svmStruct
load svm
for ii = 1:size(F1,1)
    species = svmclassify(svmStruct,F1(ii,:));
    disp([ group{ii,1} ' = ' species]);
end

for ii = 1:size(F2,1)
    species = svmclassify(svmStruct,F2(ii,:));
    disp([ group{ii+size(F1,1),1} ' = ' species]);
end


