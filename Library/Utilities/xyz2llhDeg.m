function [posLLH] = xyz2llhDeg(posXYZ)
% ---------------------------------------------------------------------------------------
% This function transforms the rectangular coordinates (x,y,z) of a point in
% ECEF frame to the geodetic coordinates in degrees (Latitude, Longitude, Height
% above the reference ellipsoid)
% 
% Input:  
%           posXYZ:     point rectangular coordinates - x,y,z (1x3)
%
% Output:
%           posLLH:     point geodetic coordinates - [Lat [deg], Lon [deg], H [m]] (1x3)
% ---------------------------------------------------------------------------------------
    
    posLLH      =   xyz_2_lla_PVT(posXYZ);
    
    posLLH(1:2) =   rad2deg(posLLH(1:2));
    
end
