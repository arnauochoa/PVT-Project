% ---------------------------------------------------------------------------------------
% This script reads the RINEX files and saves the data as MATLAB structs.
% 
% To select the file: change 'obsFilePath' and/or 'navFilePath' for observation and 
% navigation files, respectively.
% To specify output file's name: change 'dataFileName'
% ---------------------------------------------------------------------------------------

clear;

%% FILES SPECIFICATION
% Observation and Navigation RINEX files
% 'Data/Given-Meas/COM3_191005_110113_pedestrian_mp.obs';
obsFilePath     =   'Data/Given-Meas/COM44_150205_094639.obs';
navFilePath     =   'Data/Given-Meas/COM44_150205_094639.nav';

% Specification of the output file's directory and name, .mat extension.
dataFileName    =   'Data/Structs/givenData.mat';

%% READING OF FILES
% Reading RINEX files into Structures
[ObsData, ioFlag] = read_RINEX_OBS_v2(obsFilePath);
if ioFlag ~= 0, error('Error ocurred when reading OBS file.'); end

[NavData, ioFlag] = read_RINEX_NAV_v2(navFilePath);
if ioFlag ~= 0, error('Error ocurred when reading NAV file.'); end

%% SAVING STRUCTURES
save(dataFileName, 'ObsData', 'NavData');
