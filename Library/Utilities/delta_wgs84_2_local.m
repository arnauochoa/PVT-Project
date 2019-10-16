function [vXYZl, mTRANSF] = delta_wgs84_2_local(vXYZw, vXYZ0)

%--------------------------------------------------------------------------
% This function transforms the coordinates of a vector in the ECEF frame
% (WGS-84) into the coordinates of that vector into local tangent plane
% (NEU)
%
% Input Variables
%   1) vXYZw     coordinates of the vector in ECEF frame (3x1)
%   2) vXYZ0     center of local tangent plane in ECEF frame (3x1) 
%
% Output Variables
%   1) vXYZl     coordinates of the vector in local tangent plane (3x1)
%       vXYZl(1) coordinate in the North direction
%       vXYZl(2) coordinate in the East direction       
%       vXYZl(3) coordinate in the Up direction
%   2) mTRANSF   transformation matrix (3x3)
%--------------------------------------------------------------------------

vXYZl = zeros(3,1);
mTRANSF = zeros(3,3);

% Determine transformation matrix components
Posobs = xyz_2_lla_PVT(vXYZ0);
COSLAT = cos(Posobs(1));
SINLAT = sin(Posobs(1));
COSLONG = cos(Posobs(2));
SINLONG = sin(Posobs(2));
mTRANSF(1,1) = -SINLAT*COSLONG;
mTRANSF(1,2) = -SINLAT*SINLONG;
mTRANSF(1,3) = COSLAT;
mTRANSF(2,1) = -SINLONG;
mTRANSF(2,2) = COSLONG;
mTRANSF(2,3) = 0.0 ;
mTRANSF(3,1) = COSLAT*COSLONG;
mTRANSF(3,2) = COSLAT*SINLONG ;
mTRANSF(3,3) = SINLAT;

% Vector transformation
vXYZl = mTRANSF * vXYZw;