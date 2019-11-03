% ---------------------------------------------------------------------------------------
% This script computes the positions on all the epochs from the data in the 
% .mat files that can be obtained with 'readRinex.m'. The  number of epochs
% can be specified with 'nEpoch_max'.
% 
% To select the input data file: change 'dataFileName'
% ---------------------------------------------------------------------------------------
%% HEADER
close all; clc; clearvars;
addpath(genpath('Library'));

%% CONSTANTS
ephTime     =   14400;    %  [s]    Time of validity of ephemeris data

%% FILE LOADING
dataFileName = 'Data/Structs/givenData.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, Nb_Epoch, vNb_Sat, Total_Nb_Sat, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[ionoA, ionoB, mEphem] = ExtractData_N(NavData.HEADER, NavData.DATA);

%% EPOCH LOOP
for iEpoch = 1:Nb_Epoch
    
    % Find the PRNs of the tracked satellites at current epoch
    trackedPRN  =   find(mTracked(iEpoch, :)); 
    
    % Find the valid ephemeris at the current epoch (toe-2h < t < toe+2h)
    mValEphem   =   mEphem(                         ...
        mEphem(:,13) - ephTime/2 < mEpoch(iEpoch,2) ...
        &                                           ...
        mEphem(:,13) + ephTime/2 > mEpoch(iEpoch,2) ...
        , :                                         ...
    );
    
    epochTime   =   mEpoch(iEpoch,2);   % Rx time in seconds of week
    
    nTrackedSat =   length(trackedPRN);
    mSatPos     =   zeros(nTrackedSat, 3);
    
    for iSat = 1:nTrackedSat
        % Take ephemeris of current satellite
        satEphem            =   mValEphem(mValEphem(:, 1) == trackedPRN(iSat) , :);
        
        % TODO: Correct time
        satTime             =   getSatTime(satEphem, epochTime, mC1(iEpoch, iSat));
        
        mSatPos(iSat, :)    =   getSatPos(satEphem, satTime);
        
    end
    
    a=0;
    
    % TODO: Call function that iterates over LS
    
    
    % TODO: Call function to transform XYZ pos to LLH pos
    
end

%% RESULT ANALYSIS

