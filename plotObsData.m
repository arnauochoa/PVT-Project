% ---------------------------------------------------------------------------------------
% This script plots some observation data in the .mat files that can be obtained with 
% 'readRinex.m'.
% 
% To select the input data file: change 'dataFileName'
% ---------------------------------------------------------------------------------------

%% HEADER
close all; 
clc;
clearvars -except ObsData NavData
addpath(genpath('Library'));
set(groot,'defaultLineLineWidth',0.8)

%% CONSTANTS
nSats   =   32;         %    []     Total number of satellites      
c       =   299792458;  %   [m/s]   Light speed
fL1     =   1.57542e9;  %   [Hz]    Frequency of L1 band

mkSize  =   12;         %    []     Marker size for plots

%% FILE LOADING
dataFileName = 'Data/Structs/static.mat';
load(dataFileName);

%% DATA EXTRACTION
% Extraction of data into matrices
nEpoch_max = length(ObsData.DATA); % For all epochs -> length(ObsData.DATA)
[~, nEpoch, vNumSat, ~, mTracked, mC1, mL1, mD1, mS1] = ExtractData_O(ObsData.DATA, nEpoch_max);

%% COMPUTATIONS


%% PLOTS
% Variables used on plots
tAxis   =   1:nEpoch;
mColors =   jet(nSats); % Create set of different colors for plotting. 1 sat - 1 color. 

% Number of tracked satellites over time
figure;
plot(tAxis, vNumSat);
set(gca,'YTick',(min(vNumSat):1:max(vNumSat))); % Specifying Y axis steps of 1
title('Number of tracked satellites over time');
xlabel('Epoch'); ylabel('Number of tracked satellites');

% Satellites tracking detail over time
figure;
spy(mTracked.', '.', 10);
pbaspect([13 10 10]); % Changing axis' aspect ratio
set(gca,'YTick',(1:1:nSats));
title('Satellites tracking over time');
xlabel('Epoch'); ylabel('Satellite');

% Pseudoranges of satellites in view
mC1Any  =   mC1(:, any(mC1));   % Keeping columns of satellites from which there's C1
[~, col]  =   find(mC1);          
satsC1  =   unique(col);          % Finding ids of the satellites from which there's C1

mC1Any(mC1Any==0) = nan;        % Changing values 0 for NaN so these aren't plotted

figure;
for sat = 1:length(satsC1)
    plot(tAxis, mC1Any(:, sat).', '.',  'MarkerSize', mkSize,'color', mColors(satsC1(sat), :)); 
    hold on
end
hold off
legend(cellstr(num2str(satsC1)),'Location','bestoutside');
title('Evolution of measured pseudoranges over time');
xlabel('Epoch'); ylabel('Pseudorange [m]');

% CNo of satellites in view
mS1Any  =   mS1(:, any(mS1));   % Keeping columns of satellites from which there's S1
[~, col]=   find(mS1);          
satsS1  =   unique(col);          % Finding ids of the satellites from which there's S1

mS1Any(mS1Any==0) = nan;        % Changing values 0 for NaN so these aren't plotted

figure;
for sat = 1:length(satsS1)
    plot(tAxis, mS1Any(:, sat).', '.', 'MarkerSize', mkSize, 'color', mColors(satsS1(sat), :));
    hold on
end
hold off
legend(cellstr(num2str(satsS1)),'Location','bestoutside');
title('Evolution of measured C/No over time');
xlabel('Epoch'); ylabel('C/No [dB-Hz]');

% CMC for satellites in view
mL1m        =   mL1 .* c/fL1;         % Transformation from cycles to meters
mCMC1       =   mC1 - mL1;            % CMC computation
mCMC1Any    =   mCMC1(:, any(mCMC1)); % Finding numbers of satellites from which there's CMC
[~, col]      =   find(mCMC1);          
satsCMC1    =   unique(col);          % Finding ids of the satellites from which there's CMC

mCMC1Res    =   mCMC1Any - mean(mCMC1Any, 2); % Subtract the average to get rid of the ambiguity

mCMC1Res(mCMC1Res==0) = nan;        % Changing values 0 for NaN so these aren't plotted

figure;
for sat = 1:length(satsCMC1)
    plot(tAxis, mCMC1Res(:, sat).', '.', 'MarkerSize', mkSize, 'color', mColors(satsCMC1(sat), :)); 
    hold on
end
hold off
legend(cellstr(num2str(satsCMC1)),'Location','bestoutside');
title('Evolution of measured CMC - E(CMC) over time');
xlabel('Epoch'); ylabel('CMC [m]');





