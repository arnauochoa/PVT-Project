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
dataFileName    =   'Data/Structs/givenData.mat';
isStatic        =   true;     % << Change this according to type of measurements
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, nEpoch, vNumSat, totalNumSat, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[ionoA, ionoB, mEphem] = ExtractData_N(NavData.HEADER, NavData.DATA);

RefPos      =   ObsData.HEADER.ANTENNA.POSITION;
refPosXYZ   =   [RefPos.x_ECEF, RefPos.y_ECEF, RefPos.z_ECEF];
refPosLLH   =   xyz2llhDeg(refPosXYZ); 
refPosNEU   =   delta_wgs84_2_local(refPosXYZ.', refPosXYZ.').';
pvt0        =   [refPosXYZ, 0];     % Initial guess

%% Data structures initialisation
mPosXYZ     =   zeros(nEpoch, 3);
mPosLLH     =   zeros(nEpoch, 3);
tBias       =   zeros(nEpoch, 1);
timeCorr    =   zeros(32, nEpoch);
ionoCorr    =   zeros(32, nEpoch);
tropCorr    =   zeros(32, nEpoch);

%% EPOCH LOOP
for iEpoch = 1:nEpoch
        % Find the PRNs of the tracked satellites at current epoch
        trackedPRN  =   find(mTracked(iEpoch, :)); 

        % Rx time in seconds of week
        epochTime   =   mEpoch(iEpoch, 2);
        epochDoY    =   ymd2doy(mEpoch(iEpoch, 4:9).');

        trackedPRN  =   checkSatHealth(trackedPRN, mEphem, epochTime);
    if vNumSat(iEpoch) >= 4
        [pvt, timeCorr(:, iEpoch), ionoCorr(:, iEpoch), tropCorr(:, iEpoch)] = estimatePVT(...
            trackedPRN, mC1(iEpoch, :), mEphem, epochTime, epochDoY, pvt0, ionoA, ionoB);
        pvt0 = pvt;
    else
        pvt                    =   nan(1, 4);
        ionoCorr(:, iEpoch)    =   nan(32, 1);
        tropCorr(:, iEpoch)    =   nan(32, 1);
    end
    mPosXYZ(iEpoch, :)  =   pvt(1:3);
    mPosLLH(iEpoch, :)  =   xyz2llhDeg(mPosXYZ(iEpoch, :));
    tBias(iEpoch)       =   pvt(4);
end

%% COORDINATES CONVERSION
mPosNEU = delta_wgs84_2_local(mPosXYZ.', refPosXYZ.').';

%% PREFORMANCE METRICS
neuError = mPosNEU - refPosNEU;

%% RESULT ANALYSIS
timeAxis = 1:nEpoch;

figure;
grid on,
plot(neuError(:, 2), neuError(:, 1), 'x', 'MarkerSize',9); hold on;
plot(0, 0, 'x', 'Color', 'r', 'MarkerSize',9);
xlabel('Longitude [m]'); ylabel('Latitude [m]');
legend('estimated', 'reference', 'Location','best');

figure;
plot(mPosLLH(:,2), mPosLLH(:,1), '.b','MarkerSize',15); hold on;
plot(refPosLLH(2), refPosLLH(1), '.r','MarkerSize',15);
plot_google_map;


if isStatic % Plots only useful for static measurements
    figure;
    plot(timeAxis, abs(neuError(:, 1)), '.-'); hold on;
    plot(timeAxis, abs(neuError(:, 2)), '.-'); hold on;
    plot(timeAxis, abs(neuError(:, 3)), '.-');
    title('NEU error over time');
    xlabel('Epoch'); ylabel('Error [m]');
    legend('North', 'East', 'Up');

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
end




