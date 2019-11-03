function [satTime] = getSatTime(satEphem, epochTime, pr)
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
% ---------------------------------------------------------------------------------------

    % Constants
    c       =   299792458;          %   [m/s]       Speed of light
%     f       =   -4.442807633e-10;   %   [s/m^(1/2)]    
    
    toc     =   satEphem(4);        %   Epoch time of Clock
    af0     =   satEphem(6);        %   SV clock bias
    af1     =   satEphem(7);        %   SV clock drift
    af2     =   satEphem(8);        %   SV clock drift rate
    tgd     =   satEphem(9);        %   SV Time Group Delay
%     ecc     =   satEphem(15);       %   Eccentricity
%     a       =   satEphem(15)^2;     %   Semi-Major Axis
    
    
    tRaw    =   epochTime - pr/c;
    
    dtc     =   checkTime(tRaw - toc);
    dt      =   af0 + af1*dtc + af2*(dtc^2);
    
    satTime =   tRaw - dt; 
end