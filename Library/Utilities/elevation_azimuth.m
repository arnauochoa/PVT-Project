function [fElevation, fAzimuth] = elevation_azimuth(pos_origine_XYZ, pos_satellite_XYZ)

%--------------------------------------------------------------------------
% Copyright © ENAC, 2015.
% ENAC : http://www.enac.fr/.
% signav@recherche.enac.fr
%
% This function computes the elevation and azimuth angles between a single
% user position and a vector of satellite positions
% Input Variables
%   pos_origine_XYZ     reference user Earth-fixed position - [x, y, z] (1x3)
%   pos_satellite_XYZ   SV Earth-fixed position - [x, y, z] (1x3)
% Output variables
%   fElevation          SV elevation angle wrt to user - [rad]
%   fAzimuth            SV azimuth angle wrt to user - [rad]
%--------------------------------------------------------------------------


% Direction vector
XYZw = pos_satellite_XYZ - pos_origine_XYZ;

% Coordinates of the direction vector in the local reference frame
dXYZ = delta_wgs84_2_local(XYZw', pos_origine_XYZ');

% User-satellite distance
distance = sqrt(XYZw(1)^2 + XYZw(2)^2 + XYZw(3)^2);

% Direction cosine in Z at the satellite's direction
cosz = dXYZ(3)/distance;

% Elevation angle
fElevation = asin(cosz);

% Azimuth angle
fAzimuth = atan2(dXYZ(2), dXYZ(1));