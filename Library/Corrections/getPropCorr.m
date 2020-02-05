function [ionoCorr, tropoCorr, el, az]    =   getPropCorr(satPos, pvt, iono, epochTime, epochDoY)
% ---------------------------------------------------------------------------------------
% This function estimates the position and time bias of the user at a given
% epoch using the standard LS estimation method.
% 
% Input:  
%           satpos:     Position of the satellite.
%           pvt:        PVT of the user.
%           iono:       Iono correction a and b parameters (iono = [a0,a1,a2,a3,b0,b1,b2,b3]) 
%           epochTime:  Corrected time of the current epoch as SoW
%           epochDoY:   Day of Year of current epoch
%
% Output:
%           ionoCorr:   Ionospheric correction
%           tropoCorr:  Tropospheric correction
%           el:         Satellite's elevation
%           az:         Satellite's azimuth
% ---------------------------------------------------------------------------------------
    pos         =   pvt(1:3);
    
    [el, az]    =   elevation_azimuth(pos, satPos);
    
    posLLH      =   xyz_2_lla_PVT(pvt(1:3));
    height      =   posLLH(3);
    if(height <= 0)
        height  = 1;
    end
    tropoCorr   =   UNB3M(posLLH(1), height, epochDoY, el);

    ionoCorr    =   findIonoDelay(rad2deg(posLLH(1:2)), rad2deg(el), rad2deg(az), epochTime, iono);
end