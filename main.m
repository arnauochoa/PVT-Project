% ---------------------------------------------------------------------------------------
% This script computes the positions on all the epochs from the data in the 
% .mat files that can be obtained with 'readRinex.m'. The  number of epochs
% can be specified with 'nEpoch_max'.
% 
% To select the input data file: change 'dataFileName'
% ---------------------------------------------------------------------------------------
%% HEADER
close all; clc;
clearvars -except ObsData NavData
addpath(genpath('Library'));
set(groot,'defaultLineLineWidth',0.8)

%% FILE LOADING
dataFileName = 'Data/Structs/static.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, Nb_Epoch, vNb_Sat, Total_Nb_Sat, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[Iono_a, Iono_b, Ephem] = ExtractData_N(NavData.HEADER, NavData.DATA);

%% EPOCH LOOP
for iEpoch = 1:Nb_Epoch
    
    % TODO: Call function that computes satellites' positions
    
    
    % TODO: Call function that iterates over LS
    
    
    % TODO: Call function to transform XYZ pos to LLH pos
    
end

%% RESULT ANALYSIS

