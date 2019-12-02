function [pvt, ionoCorr, tropoCorr] = estimatePVT(trackedPRN, pr, mEphem, epochTime, pvt0, ionoA, ionoB)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           trackedPRN: Vector containing the numbers of the tracked satellites
%           pr:         vector containing the pseudorange of the satellites (32 x 1)
%           mEphem:     Matrix containing the ephemeris information (numSat x 29)
%           epochTime:  Corrected time of the current epoch as SoW
%           pvt0:       Initial guess of pvt.
%           ionoA:      Iono correction a-parameters (Iono_a = [a0,a1,a2,a3]) 
%           ionoB:      Iono correction b-parameters (Iono_b = [b0,b1,b2,b3])
%
% Output:
%           pvt:        Vector with X-Y-Z coordinates and time bias.
%           ionoCorr:   Vector with ionospheric corrections for all tracked satellites
%           tropoCorr:  Vector with tropospheric corrections for all tracked satellites
% ---------------------------------------------------------------------------------------

    nTrackedSat     =   length(trackedPRN);
    mSatPos         =   nan(nTrackedSat, 3);
    
    mH              =   zeros(nTrackedSat, 4);
    p               =   zeros(nTrackedSat, 1);
    pvt             =   pvt0;
    
    hasConverged    =   0;
    convThreshold   =   0.01;
    iter            =   1;
    maxIter         =   20;
    
    ionoCorr        =   zeros(1, 32);
    tropoCorr       =   zeros(1, 32);
    
    while ~hasConverged && iter <= maxIter
        for iSat = 1:nTrackedSat
            svPRN   =   trackedPRN(iSat);
            if(iter == 1)
                % Find the valid ephemeris at the current epoch for the current
                % satellite
                satEphem            =   SelectEphemeris(mEphem, svPRN, epochTime);
                
                txTime              =   getSatTxTime(satEphem, epochTime, pr(svPRN));
                mSatPos(iSat, :)    =   getSatPos(satEphem, txTime, epochTime);
            end
            
            % TODO: Apply corrections
            [ionoCorr(svPRN), tropoCorr(svPRN)]   =   getPropCorr(...
                mSatPos(iSat, :), pvt, ionoA, ionoB, epochTime);
            corr    =   ionoCorr(svPRN) + tropoCorr(svPRN);
            
            prCorr  =   pr(svPRN) - corr;
            
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
        
        % Check if values d(1:3) are lower than the convergence threshold
        hasConverged =  prod(d(1:3) < convThreshold); 
        iter        =   iter+1;
    end
end