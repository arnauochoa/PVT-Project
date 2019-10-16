%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% llh = f_xyz_2_llh(XYZ)                                                    %
%                                                                           %
% Transformation de coordonnees rectangulaires (X,Y,Z) ECEF dans le WGS-84  %
% en coordonnées (Latitude,Longitude,Hauteur)                               %
%                                                                           %
% Entrée : - XYZ : vecteur (X,Y,Z) [m]                                      %
% Sortie : - llh : vecteur (latitude,longitude,hauteur) [rad]               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function llh = f_xyz_2_llh(XYZ)

a = 6378137.0;     % Demi grand axe de l'ellipsoide de reférence WGS-84 (m)
b = 6356752.3142;  % Demi petit axe de l'ellipsoide de reférence WGS-84 (m)
f = (a-b)/a;       % Aplatissement 
e = sqrt(f*(2-f)); % Excentricité de l'ellipsoide WGS-84

p = sqrt(XYZ(1)^2+XYZ(2)^2);
E_2 = a^2-b^2;
F = 54*b^2*XYZ(3)^2;
G = p^2+(1-e^2)*XYZ(3)^2-e^2*E_2;
c = e^4*F*p^2/G^3;
s = (1+c+sqrt(c^2+2*c))^(1/3);
P = F/(3*(s+1/s+1)^2*G^2);
Q = sqrt(1+2*e^4*P);
r0 = -P*e^2*p/(1+Q)+sqrt(0.5*a^2*(1+1/Q)-P*(1-e^2)*XYZ(3)^2/(Q*(1+Q))-0.5*P*p^2);
U = sqrt((p-e^2*r0)^2+XYZ(3)^2);
V = sqrt((p-e^2*r0)^2+(1-e^2)*XYZ(3)^2);
z0 = b^2*XYZ(3)/(a*V);
e_p = a*e/b;
llh(3) = U*(1-b^2/(a*V));
llh(2) = atan2(XYZ(2),XYZ(1));
llh(1) = atan((XYZ(3)+e_p^2*z0)/p);