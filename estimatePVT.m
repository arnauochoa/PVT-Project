function [pvt] = estimatePVT(trackedPRN, pr, mEphem, epochTime)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           trackedPRN: Vector containing the numbers of the tracked satellites
%           pr:         vector containing the pseudorange of the satellites (32 x 1)
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
    pvt0        =   [0 0 0 0];
    
    mH          =   zeros(nTrackedSat, 4);
    p           =   zeros(nTrackedSat, 1);
    pvt         =   pvt0;
    
    for iter = 1:nIter
        for iSat = 1:nTrackedSat
            svPRN   =   trackedPRN(iSat);
            
            if(iter == 1)
                % Find the valid ephemeris at the current epoch for the current
                % satellite
                satEphem            =   SelectEphemeris(mEphem, svPRN, epochTime);
                % TODO: check sat's health
                txTime              =   getSatTxTime(satEphem, epochTime, pr(svPRN));
                mSatPos(iSat, :)    =   getSatPos(satEphem, txTime, epochTime);
            end
            
            % TODO: Apply corrections
            corr    =   0;
            prCorr  =   pr(svPRN) + corr;
            
            % Fill geometry matrix H and measurements vector p
            d0      =   sqrt(   (mSatPos(iSat, 1) - pvt(1))^2 + ...
                                (mSatPos(iSat, 2) - pvt(2))^2 + ...
                                (mSatPos(iSat, 3) - pvt(3))^2 );

            p(iSat) =   prCorr - d0;
            
            ax      =   -(mSatPos(iSat, 1) - pvt(1)) / d0;
            ay      =   -(mSatPos(iSat, 2) - pvt(2)) / d0;
            az      =   -(mSatPos(iSat, 3) - pvt(3)) / d0;
            
            mH(iSat, :) = [ax ay az 1];
        end
        % LS estimation of PVT at iteration iter
        d           =   pinv(mH) * p;
        pvt(1:3)    =   pvt(1:3) + d(1:3).';
        pvt(4)      =   d(4);
    end

end