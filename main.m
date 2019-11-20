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
dataFileName = 'Data/Structs/static.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = 760; % For all epochs -> length(ObsData.DATA)
[mEpoch, Nb_Epoch, vNb_Sat, Total_Nb_Sat, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[ionoA, ionoB, mEphem] = ExtractData_N(NavData.HEADER, NavData.DATA);

%% Data structures initialisation
SatPos1     =   zeros(3, Nb_Epoch); % <<<<<<<< Provisional
mPosLLH     =   zeros(Nb_Epoch, 3);

%% EPOCH LOOP
for iEpoch = 1:Nb_Epoch
    
    % Find the PRNs of the tracked satellites at current epoch
    trackedPRN  =   find(mTracked(iEpoch, :)); 
    
    % Rx time in seconds of week
    epochTime   =   mEpoch(iEpoch, 2);
    
    pvt = estimatePVT(trackedPRN, mC1(iEpoch, :), mEphem, epochTime);
    
    mPosLLH(iEpoch, :) = rad2deg(f_xyz_2_llh(pvt(1:3)));
    a=0;
end

%% RESULT ANALYSIS
figure;
plot(1:Nb_Epoch, SatPos1(1, :)); % <<<<<<<< Provisional
xlabel('Epoch'); ylabel('X coordinate');

figure;
plot(1:Nb_Epoch, SatPos1(2, :)); % <<<<<<<< Provisional
xlabel('Epoch'); ylabel('Y coordinate');

figure;
plot(1:Nb_Epoch, SatPos1(3, :)); % <<<<<<<< Provisional
xlabel('Epoch'); ylabel('Z coordinate');



