function vLLH = xyz_2_lla_PVT(vXYZ)
%--------------------------------------------------------------------------
% This function transforms the rectangular coordinates (x,y,z) of a point in
% ECEF frame to the geodetic coordinates (Latitude, Longitude, Height
% above the reference ellipsoid)
%
% Input Variables
% 1) vXYZ     point rectangular coordinates - x,y,z (1x3)
%
% Output Variables
% 2) vLLH     point geodetic coordinates - [Lat [rad], Lon [rad], H [m]] (1x3)
%--------------------------------------------------------------------------

vLLH = [0 0 0];
A = 6378137.0;
B = 6356752.3142;
EXC = 0.081819192908426;
EXC2 = 0.00669437999013;

RH = sqrt(vXYZ(1)^2 + vXYZ(2)^2);
if (RH <= 1e-15)
  vLLH(1) = pi/2;
  if (vXYZ(3) < 0.0)
    vLLH(1) = -vLLH(1);
  end
  vLLH(2) = 0;
  vLLH(3) = abs(vXYZ(3)) - B;
end
vLLH(2) = atan2(vXYZ(2),vXYZ(1));
vLLH(1) = atan2(vXYZ(3),RH);
LATV = vLLH(1) + 1;
HAUTV = vLLH(3) + 1;
while ((abs(vLLH(1)-LATV) >= 1.0e-10) || (abs(vLLH(3)-HAUTV) >= 0.01))
  LATV = vLLH(1);
  HAUTV = vLLH(3);
  D = EXC*sin(LATV);
  N = A/sqrt(1 -D*D);
  vLLH(3) = RH/cos(LATV) - N;
  NP = N + vLLH(3);
  D = 1.0 - EXC2*(N/NP);
  vLLH(1) = atan2(vXYZ(3), RH*D);
end
