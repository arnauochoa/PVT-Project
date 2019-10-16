function [mEpoch, Nb_Epoch, vNb_Sat, Total_Nb_Sat, mTracked, mC1, mL1, mD1, mS1]=ExtractData_O(DATA_O, nEpoch_max)

%--------------------------------------------------------------------------
% Copyright © ENAC, 2015.
% ENAC : http://www.enac.fr/.
% signav@recherche.enac.fr
%
% This functions extract the ephemeris data after reading the RINEX file
% .nav
% Input Variables
%   1) HEADER_O    cell containing .obs file header
%   2) DATA_O      cell containing .obs file recorded data
%       DATA_O(i).*      ith epoch data
% Output Variables
%   1) mEpoch      Time - (Nb_Epoch x 6)
%       mEpoch(i,:) = [GPS week #, time(second of week - SoW), time (number
%       of seconds since GPS date - NoS), YYYY, MM, DD, hh, mm, sec]
%   2) Nb_Epoch    Number of samples to process
%   3) vNb_Sat     Number of tracked satellites - (Nb_Epoch x 1)
%       vNb_Sat(i) = number of tracked satellites at epoch i
%   4) Total_Nb_Sat  Total number of tracked satellites
%   5) mTracked    Matrix of booleans that indicates when satellites
%   are tracked - (Nb_Epoch x 32)
%       mTracked(i,j) = 1, if PRN j is tracked at epoch i
%       mTracked(i,j) = 0, otherwise
%   6) mC1         L1 C/A code pseudorange - (Nb_Epoch x 32)
%       mC1(i,j) = code pseudorange of PRN j satellite at epoch i
%   7) mL1         L1 Carrier phase - (Nb_Epoch x 32)
%       mL1(i,j) = carrier phase of PRN j satellite at epoch i
%   8) mD1         L1 Doppler frequency - (Nb_Epoch x 32)
%       mL1(i,j) = doppler frequency of PRN j satellite at epoch i
%   9) mS1         L1 SNR value as given by Rx - (Nb_Epoch x 32)
%       mS1(i,j) = SNR value of PRN j satellite at epoch i
%--------------------------------------------------------------------------

% Initialize Variables
Nb_Epoch = [];
mEpoch = [];
vNb_Sat = [];
mTracked = [];
mC1 = [];
mL1 = [];
mD1 = [];
mS1 = [];
% Total number of different satellites tracked
Total_Nb_Sat = 0;

% Number of epochs (number of samples)
Nb_Epoch = length(DATA_O);
% Limit the number of epochs to process
if (Nb_Epoch > nEpoch_max), Nb_Epoch = nEpoch_max; end

% Extract data
mEpoch = zeros(Nb_Epoch,9);
vNb_Sat = zeros(Nb_Epoch,1);
mTracked_PRN = zeros(Nb_Epoch,32);
mC1 = zeros(Nb_Epoch,32);
mL1 = zeros(Nb_Epoch,32);
mD1 = zeros(Nb_Epoch,32);
mS1 = zeros(Nb_Epoch,32);

for i=1:Nb_Epoch, % For each epoch
    
    % Extract time information at epoch i
    mEpoch(i,1) = DATA_O(i).EPOCH.GPSTIME.GPS_Week;
    mEpoch(i,2) = DATA_O(i).EPOCH.GPSTIME.SoW;
    mEpoch(i,3) = DATA_O(i).EPOCH.GPSTIME.NoS;
    mEpoch(i,4) = DATA_O(i).EPOCH.GREGORIAN.year;
    mEpoch(i,5) = DATA_O(i).EPOCH.GREGORIAN.month;
    mEpoch(i,6) = DATA_O(i).EPOCH.GREGORIAN.day;
    mEpoch(i,7) = DATA_O(i).EPOCH.TIME.hour;
    mEpoch(i,8) = DATA_O(i).EPOCH.TIME.min;
    mEpoch(i,9) = DATA_O(i).EPOCH.TIME.sec;

    % Extract number of tracked satellites at epoch i
    vNb_Sat(i) = length(DATA_O(i).PRNs);
    
    for j=1:vNb_Sat(i), % For each tracked satellite at epoch i
        % Get PRN # of the tracked satellite
        iPRN_ID = []; iPRN_ID = DATA_O(i).PRNs(j);
        % Fill in the boolean matrix mTracked_PRN
        mTracked(i,iPRN_ID) = 1;
        % Extract L1 C/A code pseudorange measurement
        mC1(i,iPRN_ID) = DATA_O(i).OBS(j).C1;
        % Extract L1 carrier phase measurement
        mL1(i,iPRN_ID) = DATA_O(i).OBS(j).L1;
        % Extract L1 doppler frequency measurement
        mD1(i,iPRN_ID) = DATA_O(i).OBS(j).D1;
        % Extract S1 SNR value as given by the receiver
        mS1(i,iPRN_ID) = DATA_O(i).OBS(j).S1;
    end
    
end

% Total number of different satellites tracked
Total_Nb_Sat = nnz(sum(mTracked,1));    







