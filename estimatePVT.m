function [pvt, timeCorr, ionoCorr, tropCorr, mSatPos, dop, usedPRN] = ...
    estimatePVT(usedPRN, pr, mEphem, epochTime, epochDoY, pvt0, iono, cn0, elevMask, cn0Mask)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           usedPRN:    Vector containing the numbers of the used satellites
%           pr:         vector containing the pseudorange of the satellites (32 x 1)
%           mEphem:     Matrix containing the ephemeris information (numSat x 29)
%           epochTime:  Corrected time of the current epoch as SoW
%           epochDoY:   Day of Year of current epoch
%           pvt0:       Initial guess of pvt.
%           iono:       Iono correction a and b parameters (iono = [a0,a1,a2,a3,b0,b1,b2,b3]) 
%           cn0:        Vector containing the C/N0 of all satellites at current epoch
%           elevMask:   Elevation mask in degrees
%           cn0Mask:    C/N0 mask in dB-Hz
%
% Output:
%           pvt:        Vector with X-Y-Z coordinates and time bias.
%           timeCorr;   Vector with clock corrections for all tracked satellites
%           ionoCorr:   Vector with ionospheric corrections for all tracked satellites
%           tropoCorr:  Vector with tropospheric corrections for all tracked satellites
%           mSatPos:    Matrix with the satellites' positions
%           dop:        Vector with the DOP values (dop = [DOPe DOPn DOPv DOPt])
% ---------------------------------------------------------------------------------------

    global nSats weightMode

    %% INITIALISATION OF VARIABLES
    nUsedSat     =   length(usedPRN);
    
    pvt             =   pvt0;
    
    hasConverged    =   0;
    convThreshold   =   0.0001;
    iter            =   1;
    maxIter         =   10;
    
    timeCorr        =   zeros(nSats, 1);
    ionoCorr        =   zeros(nSats, 1);
    tropCorr        =   zeros(nSats, 1);
    mSatPos         =   nan(nSats, 3);
    mElAz           =   zeros(nSats, 2);
    
    for iSat = 1:nUsedSat
        svPRN   =   usedPRN(iSat);
        % Find the valid ephemeris at the current epoch for the current
        % satellite
        satEphem                =   SelectEphemeris(mEphem, svPRN, epochTime);

        [txTime, timeCorr(svPRN)]  =   getSatTxTime(satEphem, epochTime, pr(svPRN));
        mSatPos(svPRN, :)       =   getSatPos(satEphem, txTime, epochTime);
    end
    % Applying mask
    usedPRN = applyMask(usedPRN, mSatPos, pvt(1:3), cn0, elevMask, cn0Mask);
    
    nUsedSat     =   length(usedPRN);
    
    mH              =   zeros(nUsedSat, 4);
    p               =   zeros(nUsedSat, 1);
    prCorr          =   zeros(nUsedSat, 1);
    weights         =   zeros(nUsedSat, 1);
    
    %% ITERATIVE LS ESTIMATION
    if length(usedPRN)>= 4
        while ~hasConverged && iter <= maxIter
            for iSat = 1:nUsedSat
                svPRN   =   usedPRN(iSat);

                [el, ~]         =   elevation_azimuth(pvt(1:3), mSatPos(svPRN, :));

                weights(iSat)   =   getWeight(el, cn0(svPRN), weightMode);

                % Apply corrections
                [ionoCorr(svPRN), tropCorr(svPRN), mElAz(svPRN, 1), mElAz(svPRN, 2)] = ...
                    getPropCorr(mSatPos(svPRN, :), pvt, iono, epochTime, epochDoY);
                corr    =   ionoCorr(svPRN) + tropCorr(svPRN) - timeCorr(svPRN);

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
            mW          =   diag(weights);
            if cond(mH.' * mW * mH) > 1e10
                cond(mH.' * mW * mH)
            end
            d           =   (mH.' * mW * mH) \ mH.' *  mW * p;
            pvt(1:3)    =   pvt(1:3) + d(1:3).';
            pvt(4)      =   d(4);

            % Check if values d(1:3) are lower than the convergence threshold
            hasConverged =  prod(abs(d(1:3)) < convThreshold); 
            iter        =   iter+1;
        end
        dop = sqrt(diag(inv(mH'*mH)));
    else
        pvt         =   nan(1, 4);
        dop         =   nan(1, 4);
        timeCorr    =   nan(32, 1);
        ionoCorr    =   nan(32, 1);
        tropCorr    =   nan(32, 1);
    end
end