function [ionoCorr, tropoCorr, el, az]    =   getPropCorr(satPos, pvt, ionoA, ionoB, epochTime)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           satpos:     Position of the satellite.
%           pvt:        PVT of the user.
%           ionoA:      Iono correction a-parameters (Iono_a = [a0,a1,a2,a3]) 
%           ionoB:      Iono correction b-parameters (Iono_b = [b0,b1,b2,b3])
%           epochTime:  Corrected time of the current epoch as SoW
%
% Output:
%           ionoCorr:   Ionospheric correction
%           tropoCorr:  Tropospheric correction
%           el:         Satellite's elevation
%           az:         Satellite's azimuth
% ---------------------------------------------------------------------------------------
    c           =   299792458;       %   Speed of light (m/s)

    pos         =   pvt(1:3);
    
    [el, az]    =   elevation_azimuth(pos, satPos);
    
    posLLH      =   xyz_2_lla_PVT(pvt(1:3));
    
%     tropoCorr   =   findTropoCorr(el, posLLH(3));  UNB3M

    ionoCorr    =   c * findIonoDelay(posLLH(1:2), el, az, epochTime, ionoA, ionoB);

    tropoCorr = 0;
end