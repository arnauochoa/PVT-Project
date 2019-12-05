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
refLatLng      =    [43.56475, 1.48171]; % givenData: 43.56475, 1.48171, static: 43.563450, 1.484558

%% FILE LOADING
dataFileName = 'Data/Structs/givenData.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, Nb_Epoch, vNb_Sat, Total_Nb_Sat, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[ionoA, ionoB, mEphem] = ExtractData_N(NavData.HEADER, NavData.DATA);

%% Data structures initialisation
mPosLLH     =   zeros(Nb_Epoch, 3);
pvt         =   [...  % Initial guess
                ObsData.HEADER.ANTENNA.POSITION.x_ECEF ...
                ObsData.HEADER.ANTENNA.POSITION.x_ECEF ...
                ObsData.HEADER.ANTENNA.POSITION.x_ECEF ...
                0];          
ionoCorr    =   zeros(Nb_Epoch, 32);
tropoCorr   =   zeros(Nb_Epoch, 32);

%% EPOCH LOOP
for iEpoch = 1:Nb_Epoch
    
    % Find the PRNs of the tracked satellites at current epoch
    trackedPRN  =   find(mTracked(iEpoch, :)); 
    
    % Rx time in seconds of week
    epochTime   =   mEpoch(iEpoch, 2);
    
    trackedPRN  =   checkSatHealth(trackedPRN, mEphem, epochTime);
    
    [pvt, ionoCorr(iEpoch, :), tropoCorr(iEpoch, :)] =   estimatePVT(...
        trackedPRN, mC1(iEpoch, :), mEphem, epochTime, pvt, ionoA, ionoB);
    
    mPosLLH(iEpoch, :) = rad2deg(f_xyz_2_llh(pvt(1:3)));
    a=0;
end

%% RESULT ANALYSIS
figure;
grid on,
plot(mPosLLH(:, 2), mPosLLH(:, 1), 'x', 'MarkerSize',9); hold on;
plot(refLatLng(2), refLatLng(1), 'x', 'Color', 'r', 'MarkerSize',9);
xlabel('Longitude [deg]'); ylabel('Latitude [deg]');
legend('estimated', 'reference', 'Location','best')



