%% HEADER
close all; 
clc;
clearvars -except ObsData NavData
addpath(genpath('Library'));
set(groot,'defaultLineLineWidth',0.8)

%% FILE LOADING
dataFileName = 'Data/Structs/multipath_2.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, nEpoch, vNumSat, ~, mTracked, mC1, mL1, mD1, mS1] = ExtractData_O(ObsData.DATA, nEpoch_max);

tAxis   =   1:nEpoch;

figure
for i = 1:32
    plot(tAxis, (mC1(:, i) - (mL1(:, i)*299792458/1.57542e9))/10e5, '.'); hold on;
end