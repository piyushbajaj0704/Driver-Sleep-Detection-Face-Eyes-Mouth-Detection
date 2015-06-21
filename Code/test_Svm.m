clc;
clear all;
close all;
%%
load fisheriris
xdata = meas(51:end,3:4);
%Find a line separating the Fisher iris data on versicolor and virginica species, according to the petal length and petal width measurements. 
%These two species are in rows 51 and higher of the data set, and the petal length and width are the third and fourth columns.

group = species(51:end);
svmStruct = svmtrain(xdata,group,'showplot',true);
%svmtrain(Training,Group,Name,Value) returns a structure with additional options 
%specified by one or more Name,Value pair arguments.

species = svmclassify(svmStruct,[5 2]);