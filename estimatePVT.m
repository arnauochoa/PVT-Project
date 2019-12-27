function [pvt, ionoCorr, tropCorr] = ...
    estimatePVT(trackedPRN, pr, mEphem, epochTime, epochDoY, pvt0, ionoA, ionoB)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           trackedPRN: Vector containing the numbers of the tracked satellites
%           pr:         vector containing the pseudorange of the satellites (32 x 1)
%           mEphem:     Matrix containing the ephemeris information (numSat x 29)
%           epochTime:  Corrected time of the current epoch as SoW
%           epochDoY:   Day of Year of current epoch
%           pvt0:       Initial guess of pvt.
%           ionoA:      Iono correction a-parameters (Iono_a = [a0,a1,a2,a3]) 
%           ionoB:      Iono correction b-parameters (Iono_b = [b0,b1,b2,b3])
%
% Output:
%           pvt:        Vector with X-Y-Z coordinates and time bias.
%           ionoCorr:   Vector with ionospheric corrections for all tracked satellites
%           tropoCorr:  Vector with tropospheric corrections for all tracked satellites
% ---------------------------------------------------------------------------------------

    %% CONSTANTS
    c       =   299792458;       %   Speed of light (m/s)

    %% INITIALISATION OF VARIABLES
    nTrackedSat     =   length(trackedPRN);
    
    mH              =   zeros(nTrackedSat, 4);
    p               =   zeros(nTrackedSat, 1);
    prCorr          =   zeros(nTrackedSat, 1);
    pvt             =   pvt0;
    
    hasConverged    =   0;
    convThreshold   =   0.0001;
    iter            =   1;
    maxIter         =   10;
    
    tCorr           =   zeros(32, 1);
    ionoCorr        =   zeros(32, 1);
    tropCorr       =   zeros(32, 1);
    mSatPos         =   nan(32, 3);
    mElAz           =   zeros(32, 2);
    
    %% ITERATIVE LS ESTIMATION
    while ~hasConverged && iter <= maxIter
        for iSat = 1:nTrackedSat
            svPRN   =   trackedPRN(iSat);
            if(iter == 1)
                % Find the valid ephemeris at the current epoch for the current
                % satellite
                satEphem                =   SelectEphemeris(mEphem, svPRN, epochTime);
                
                [txTime, tCorr(svPRN)]  =   getSatTxTime(satEphem, epochTime, pr(svPRN));
                mSatPos(svPRN, :)       =   getSatPos(satEphem, txTime, epochTime);
            end
            
            % Apply corrections
            [ionoCorr(svPRN), tropCorr(svPRN), mElAz(svPRN, 1), mElAz(svPRN, 2)] = ...
                getPropCorr(mSatPos(svPRN, :), pvt, ionoA, ionoB, epochTime, epochDoY);
            corr    =   ionoCorr(svPRN) + tropCorr(svPRN) - c*tCorr(svPRN);
            
            prCorr(iSat)  =   pr(svPRN) - corr;
            
            % Fill geometry matrix H and measurements vector p
            d0      =   sqrt(   (mSatPos(svPRN, 1) - pvt(1))^2 + ...
                                (mSatPos(svPRN, 2) - pvt(2))^2 + ...
                                (mSatPos(svPRN, 3) - pvt(3))^2 );

            p(iSat) =   prCorr(iSat) - d0;
            
            ax      =   -(mSatPos(svPRN, 1) - pvt(1)) / d0;
            ay      =   -(mSatPos(svPRN, 2) - pvt(2)) / d0;
            az      =   -(mSatPos(svPRN, 3) - pvt(3)) / d0;
            
            mH(iSat, :) = [ax ay az 1];
        end
        % LS estimation of PVT at iteration iter
        d           =   pinv(mH) * p;
        pvt(1:3)    =   pvt(1:3) + d(1:3).';
        pvt(4)      =   d(4);
        
        % Check if values d(1:3) are lower than the convergence threshold
        hasConverged =  abs(prod(d(1:3))) < convThreshold; 
        iter        =   iter+1;
    
%         a = ionoCorr(find(ionoCorr))
    end
end