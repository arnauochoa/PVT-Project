% ---------------------------------------------------------------------------------------
% This script computes the positions on all the epochs from the data in the 
% .mat files that can be obtained with 'readRinex.m'. The  number of epochs
% can be specified with 'nEpoch_max'.
% 
% To select the input data file: change 'dataFileName'
% ---------------------------------------------------------------------------------------
%% HEADER
close all;
clc; clearvars;
addpath(genpath('Library'));
set(groot,'defaultLineLineWidth',0.8)
% plotObsData;
%% CONSTANTS
global nSats weightMode corrMode

nSats               =   32;         % Total number of satellites  
mkSize              =   12;         % Marker size for plots
mColors             =   jet(nSats); % Create set of different colors for plotting. 1 sat - 1 color. 

%% CONFIG PARAMS
corrMode            =   {'clck', 'iono', 'trop'};  % {'clck', 'iono', 'trop'}
weightMode          =   0;          % Valid values: 0 to 5. See getWeight for more details
elevMask            =   0;          %  [deg]    Elevation mask
cn0Mask             =   0;         % [dB-Hz]   C/N0 mask
removeSats          =   [10 23 27 28];     % [10 23 27 28];

%% FILE LOADING
dataFileName        =   'Data/Structs/static.mat';
isStatic            =   true;     % << Change this according to type of measurements
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[mEpoch, nEpoch, vNumSat, ~, mTracked, mC1, mL1, mD1, mS1] = ...
    ExtractData_O(ObsData.DATA, nEpoch_max);

[ionoA, ionoB, mEphem] = ExtractData_N(NavData.HEADER, NavData.DATA);
iono        =   [ionoA, ionoB];

% RefPos      =   ObsData.HEADER.ANTENNA.POSITION;
% refPosXYZ   =   [RefPos.x_ECEF, RefPos.y_ECEF, RefPos.z_ECEF];
% refPosLLH   =   xyz2llhDeg(refPosXYZ); 
% For measurements at football field
refPosXYZ   =   [4627625, 119930, 4373207];
refPosLLH   =   [43.563448, 1.484557, 195];
refPosNEU   =   delta_wgs84_2_local(refPosXYZ.', refPosXYZ.').';
pvt0        =   [refPosXYZ, 0];     % Initial guess

%% Data structures initialisation
mPosXYZ     =   zeros(nEpoch, 3);
mPosLLH     =   zeros(nEpoch, 3);
tBias       =   zeros(nEpoch, 1);
timeCorr    =   zeros(nSats, nEpoch);
ionoCorr    =   zeros(nSats, nEpoch);
tropCorr    =   zeros(nSats, nEpoch);
mElev       =   zeros(nEpoch, nSats);
mAzim       =   zeros(nEpoch, nSats);
mXYZTDOP    =   zeros(nEpoch, 4);
mNEUDOP     =   zeros(nEpoch, 3);
mSatPos     =   nan(nSats, 3);
mUsedSats   =   zeros(nEpoch, nSats);
nUsedSats   =   zeros(nEpoch, 1);

%% EPOCH LOOP
for iEpoch = 1:nEpoch
    % Find the PRNs of the tracked satellites at current epoch
    trackedPRN  =   find(mTracked(iEpoch, :));
    usedPRN     =   setdiff(trackedPRN, removeSats);
    
    % Rx time in seconds of week
    epochTime   =   mEpoch(iEpoch, 2);
    epochDoY    =   ymd2doy(mEpoch(iEpoch, 4:9).');

    usedPRN  =   checkSatHealth(usedPRN, mEphem, epochTime);
    
    [   pvt,                    ...
        timeCorr(:, iEpoch),    ...
        ionoCorr(:, iEpoch),    ...
        tropCorr(:, iEpoch),    ...
        mSatPos,                ...
        mXYZTDOP(iEpoch, :),    ...
        mNEUDOP(iEpoch, :),     ...
        usedPRN                 ...
    ] = estimatePVT(            ...
        usedPRN,                ...
        mC1(iEpoch, :),         ...
        mEphem,                 ...
        epochTime,              ...
        epochDoY,               ...
        pvt0,                   ...
        iono,                   ...
        mS1(iEpoch, :),         ...
        elevMask,               ...
        cn0Mask                 ...
    );
    nUsedSats(iEpoch) = length(usedPRN);
    if ~any(isnan(pvt))
        pvt0 = pvt;
    end
    mUsedSats(iEpoch, usedPRN)  =   1;
    for svPRN = usedPRN
        [elevRad, azimRad]   =  elevation_azimuth(pvt0(1:3), mSatPos(svPRN, :));
        mElev(iEpoch, svPRN) =  rad2deg(elevRad);
        mAzim(iEpoch, svPRN) =  rad2deg(azimRad);
    end
    mPosXYZ(iEpoch, :)  =   pvt(1:3);
    mPosLLH(iEpoch, :)  =   xyz2llhDeg(mPosXYZ(iEpoch, :));
    tBias(iEpoch)       =   pvt(4);
end

%% COORDINATES CONVERSION
mPosNEU = delta_wgs84_2_local(mPosXYZ.', refPosXYZ.').';

%% PREFORMANCE METRICS
neuError    =   mPosNEU - refPosNEU;
xyzError    =   mPosXYZ - refPosXYZ;
hDOP        =   sqrt(mNEUDOP(:, 1).^2 + mNEUDOP(:, 2).^2);
vDOP        =   mNEUDOP(:,3);   
pDOP        =   sqrt(mXYZTDOP(:, 1).^2 + mXYZTDOP(:, 2).^2 + mXYZTDOP(:, 3).^2);
tDOP        =   mXYZTDOP(:, 4);
gDOP        =   sqrt(mXYZTDOP(:, 1).^2 + mXYZTDOP(:, 2).^2 + mXYZTDOP(:, 3).^2 + mXYZTDOP(:, 4).^2);

meanPosLLH  =   mean(mPosLLH);
stdPosNEU   =   std(mPosNEU);
horError    =   sqrt(neuError(:, 1).^2 + neuError(:, 2).^2);
errPrctile  =   prctile(horError, 95);
errPrctileLat  =   prctile(neuError(:, 1), 95);
errPrctileLon  =   prctile(neuError(:, 2), 95);
estHorBias  =   sqrt((meanPosLLH(1)-refPosLLH(1))^2 + (meanPosLLH(2)-refPosLLH(2))^2);
fprintf("Horizontal error at 95 Percentile: %f m\n", errPrctile);
fprintf("Horizontal error at 95 Percentile: Lat = %f m; Lon = %f m\n", errPrctileLat, errPrctileLon);
fprintf("Estimated bias: %f m\n", estHorBias);
fprintf("STD: \n\t North: %f m\n\t East: %f m\n\t Up: %f m\n", stdPosNEU(1), stdPosNEU(2), stdPosNEU(3));

% meanPosXYZ  =   mean(mPosXYZ);
% stdPosXYZ   =   std(mPosXYZ);
% fprintf("STD: \n\t X: %f m\n\t Y: %f m\n\t Z: %f m\n", stdPosXYZ(1), stdPosXYZ(2), stdPosXYZ(3));

fprintf("DOP: \t\t MIN \t MAX \n\tHDOP: %f \t %f \n\tVDOP: %f \t %f \n\tPDOP: %f \t %f \n", ...
    min(hDOP), max(hDOP), min(vDOP), max(vDOP), min(pDOP), max(pDOP));
fprintf("Number of used satellites: %d - %d\n", min(nUsedSats), max(nUsedSats));

% RESULT ANALYSIS
timeAxis = 1:nEpoch;

% HDOP VDOP over time
figure;
plot(timeAxis, hDOP); hold on;
plot(timeAxis, vDOP);
xlabel('Epoch'); ylabel('DOP');
legend({'HDOP', 'VDOP'}, 'Location', 'best');
% 
% % Satellites use detail over time
figure;
spy(mUsedSats.', '.', 10);
pbaspect([13 10 10]); % Changing axis' aspect ratio
set(gca,'YTick',(1:1:nSats));
title('Satellites use over time');
xlabel('Epoch'); ylabel('Satellite');

% Elevation of satellites in view
mElevAny  =   mElev(:, any(mElev)); % Keeping columns of satellites from which there's elevation
[~, col]  =   find(mElev);          
satsElev  =   unique(col);          % Finding ids of the satellites from which there's elevation
mElevAny(mElevAny==0) = nan;        % Changing values 0 for NaN so these aren't plotted
figure;
for sat = 1:length(satsElev)
    plot(timeAxis, mElevAny(:, sat).', '.',  'MarkerSize', mkSize,'color', mColors(satsElev(sat), :)); 
    hold on
end
hold off
legend(cellstr(num2str(satsElev)),'Location','bestoutside');
% title('Evolution of satellites elevations over time');
xlabel('Epoch'); ylabel('Elevation [º]');

% % Azimuth of satellites in view
% mAzimAny  =   mAzim(:, any(mAzim)); % Keeping columns of satellites from which there's azimuth
% [~, col]  =   find(mAzim);          
% satsAzim  =   unique(col);          % Finding ids of the satellites from which there's azimuth
% mAzimAny(mAzimAny==0) = nan;        % Changing values 0 for NaN so these aren't plotted
% figure;
% for sat = 1:length(satsAzim)
%     plot(timeAxis, mAzimAny(:, sat).', '.',  'MarkerSize', mkSize,'color', mColors(satsAzim(sat), :)); 
%     hold on
% end
% hold off
% legend(cellstr(num2str(satsAzim)),'Location','bestoutside');
% % title('Evolution of satellites azimuth over time');
% xlabel('Epoch'); ylabel('Azimuth [º]');

% NEU Error
% figure;
% grid on,
% plot(neuError(:, 2), neuError(:, 1), 'x', 'MarkerSize',9); hold on;
% plot(0, 0, 'x', 'Color', 'r', 'MarkerSize',9);
% xlabel('Longitude [m]'); ylabel('Latitude [m]');
% legend('estimated', 'reference', 'Location','best');

% NEU positions on maps
figure;
plot(mPosLLH(:,2), mPosLLH(:,1), '.b','MarkerSize',15); hold on;
if isStatic
    plot(refPosLLH(2), refPosLLH(1), '.r','MarkerSize',18); hold on;
    plot(meanPosLLH(2), meanPosLLH(1), '.g','MarkerSize',18);
end
plot_google_map('MapScale', 1);
xlabel('East [º]'); ylabel('North [º]');

if isStatic % Plots only useful for static measurements
    % NEU Error over time
    figure;
    plot(timeAxis, neuError(:, 1), '.-'); hold on;
    plot(timeAxis, neuError(:, 2), '.-'); hold on;
    plot(timeAxis, neuError(:, 3), '.-');
    title('NEU error over time');
    xlabel('Epoch'); ylabel('Error [m]');
    legend('North', 'East', 'Up');
    
    % XYZ Error over time
    figure;
    plot(timeAxis, xyzError(:, 1), '.-'); hold on;
    plot(timeAxis, xyzError(:, 2), '.-'); hold on;
    plot(timeAxis, xyzError(:, 3), '.-');
%     title('NEU error over time');
    xlabel('Epoch'); ylabel('Error [m]');
    legend('X', 'Y', 'Z');
    
    % CDF Lat - Long
    figure;
    ecdf(abs(neuError(:, 1))); hold on;
    ecdf(abs(neuError(:, 2)));
%     title('CDF of error in Latitude and Longitude');
    legend('Latitude', 'Longitude');
    xlabel('Coordinate error [m]');

%    CDF Height
    figure;
    ecdf(abs(neuError(:, 3))); hold on;
%     title('CDF of error in Height');
    xlabel('Height error [m]');
end




