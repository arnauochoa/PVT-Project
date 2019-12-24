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
% refPosLLH = [43.563450, 1.484557, 150]; % For measurements at football field

%% FILE LOADING
dataFileName = 'Data/Structs/givenData.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, nEpoch, vNumSat, totalNumSat, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[ionoA, ionoB, mEphem] = ExtractData_N(NavData.HEADER, NavData.DATA);

RefPos      =   ObsData.HEADER.ANTENNA.POSITION;
refPosXYZ   =   [RefPos.x_ECEF, RefPos.y_ECEF, RefPos.z_ECEF];
refPosLLH   =   rad2deg(f_xyz_2_llh(refPosXYZ)); 
refPosNEU   =   delta_wgs84_2_local(refPosXYZ.', refPosXYZ.').';

%% Data structures initialisation
mPosXYZ     =   zeros(nEpoch, 3);
mPosLLH     =   zeros(nEpoch, 3);
tBias       =   zeros(nEpoch, 1);
pvt         =   [...  % Initial guess
                ObsData.HEADER.ANTENNA.POSITION.x_ECEF ...
                ObsData.HEADER.ANTENNA.POSITION.x_ECEF ...
                ObsData.HEADER.ANTENNA.POSITION.x_ECEF ...
                0];          
ionoCorr    =   zeros(32, nEpoch);
tropoCorr   =   zeros(32, nEpoch);

%% EPOCH LOOP
for iEpoch = 1:nEpoch
    
    % Find the PRNs of the tracked satellites at current epoch
    trackedPRN  =   find(mTracked(iEpoch, :)); 
    
    % Rx time in seconds of week
    epochTime   =   mEpoch(iEpoch, 2);
    
    trackedPRN  =   checkSatHealth(trackedPRN, mEphem, epochTime);
    
    [pvt, ionoCorr(:, iEpoch), tropoCorr(:, iEpoch)] =   estimatePVT(...
        trackedPRN, mC1(iEpoch, :), mEphem, epochTime, pvt, ionoA, ionoB);
    
    mPosXYZ(iEpoch, :) = pvt(1:3);
    mPosLLH(iEpoch, :) = rad2deg(f_xyz_2_llh(mPosXYZ(iEpoch, :)));
    tBias(iEpoch) = pvt(4);
    a=0;
end

%% COORDINATES CONVERSION
mPosNEU = delta_wgs84_2_local(mPosXYZ.', refPosXYZ.').';

%% PREFORMANCE METRICS
neuError = mPosNEU - refPosNEU;

%% RESULT ANALYSIS
figure;
grid on,
plot(neuError(:, 2), neuError(:, 1), 'x', 'MarkerSize',9); hold on;
plot(0, 0, 'x', 'Color', 'r', 'MarkerSize',9);
xlabel('Longitude [m]'); ylabel('Latitude [m]');
legend('estimated', 'reference', 'Location','best');

figure;
ecdf(abs(neuError(:, 1))); hold on;
ecdf(abs(neuError(:, 2)));
title('CDF of error in Latitude and Longitude');
legend('Latitude', 'Longitude');
xlabel('Coordinate error (m)');

figure;
ecdf(abs(neuError(:, 3))); hold on;
title('CDF of error in Height');
xlabel('Height error (m)');

figure;
plot(mPosLLH(:,2), mPosLLH(:,1), '.b','MarkerSize',15); hold on;
plot(refPosLLH(2), refPosLLH(1), '.r','MarkerSize',15);
plot_google_map;



