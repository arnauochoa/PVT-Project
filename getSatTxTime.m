function [txTime, tCorr] = getSatTxTime(satEphem, epochTime, pr)
% ---------------------------------------------------------------------------------------
% This function estimates the transmission time of a satellite at a given epoch.
% 
% Input:  
%           satEphem:   Ephemeris recorded data of given satellite - (1 x 29) vector
%           epochTime:  Corrected time of the current epoch as SoW
%           pr:         Pseudorange with given satellite
%
% Output:
%           satTime:    Corrected time of the satellite.
%           tCorr:      Time bias correction for given satellite
% ---------------------------------------------------------------------------------------

    % Constants
    c       =   299792458;          %   [m/s]       Speed of light
    F       =   -4.442807633e-10;   %  [m^3/s^2]    ***
    mu      =   3.986005e14;        %  ****
    
    
    toc     =   satEphem(4);        %   Epoch time of Clock
    af0     =   satEphem(6);        %   SV clock bias
    af1     =   satEphem(7);        %   SV clock drift
    af2     =   satEphem(8);        %   SV clock drift rate
    tgd     =   satEphem(9);        %   SV Time Group Delay
    sqrtA   =   satEphem(16);       %   Square root of semi-major axis
    ecc     =   satEphem(15);       %   Eccentricity
    t0e     =   satEphem(13);       %   Ephemerides reference epoch in seconds of the week
    deltaN  =   satEphem(23);       %   Mean motion difference
    m0      =   satEphem(22);       %   Mean anomaly at reference epoch 
    
    tRaw    =   epochTime - pr/c;
    
    dtc     =   checkTime(tRaw - toc);
    
    dt      =   af0 + af1*dtc + af2*(dtc^2) - tgd;
    
    txTime  =   tRaw - dt; 
    
    tK      =   txTime - t0e;
    tK      =   checkTime(tK);

    mK      =   m0 + (sqrt(mu)/sqrtA^3 + deltaN) * tK;
    mK      =   rem(mK + 2*pi, 2*pi);
    
    eK      =   findEccAnomaly(mK, ecc);
    
    dtRel   =   F * ecc * sqrtA * sin(eK);
    
    txTime  =   txTime - dtRel;
    tCorr   =   dt + dtRel;
end

