function [pvt] = estimatePVT(trackedPRN, pr, mEphem, epochTime)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           trackedPRN: Vector containing the numbers of the tracked satellites
%           pr:         vector containing the pseudorange of the satellites
%           mEphem:     Matrix containing the ephemeris information (numSat x 29)
%           epochTime:  Corrected time of the current epoch as SoW
%           
%
% Output:
%           pvt:        Vector with X-Y-Z coordinates and time bias.
% ---------------------------------------------------------------------------------------

    nIter       =   20;
    nTrackedSat =   length(trackedPRN);
    mSatPos     =   nan(nTrackedSat, 3);
    pvt0        =   [0 0 0 0].';
    
    for iter = 1:nIter
        
        for iSat = 1:nTrackedSat
            svPRN   =   trackedPRN(iSat);

            % Find the valid ephemeris at the current epoch for the current
            % satellite
            satEphem            =   SelectEphemeris(mEphem, svPRN, epochTime);

            % TODO: check sat's health

            txTime              =   getSatTxTime(satEphem, epochTime, pr(svPRN));

            mSatPos(iSat, :)    =   getSatPos(satEphem, txTime, epochTime);

            % TODO: Apply corrections
        end
    
    end
    

    pvt = [0 0 0 0].';
end