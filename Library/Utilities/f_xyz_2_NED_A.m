%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NED = f_xyz_2_NED_A(XYZw, XYZ0)                                           %
%                                                                           %
% Conversion des coordonnees d'un vecteur exprimees dans le WGS84 en un     %
% vecteur dans le repere local NED. Formule de [Salychev]                   %
%                                                                           %
% Entrées : - XYZw : vecteur ligne devant etre converti, exprimé en         %
%             rectangulaire dans le WGS-84                                  %
%           - XYZ0 : position de l'origine du repère local, exprimé en      %
%             rectangulaire dans le WGS-84 (vecteur ligne)                  %
%                                                                           %
% Sortie :  - local : vecteur contenant le coordonnées de XYZw dans le      %
%             repère local (Nord (m), East (m), Bas (m))                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NED = f_xyz_2_NED_A(XYZw, XYZ0)

XYZ = XYZw - XYZ0;            % Récupération du vecteur "centre du repère local -> satellite"
llhREF = f_xyz_2_llh(XYZ0); % Récupération des coordonées llh caractérisant l'originie du repère local

% Définition de la matrice de changement de repère WGS-84->local
COSLAT = cos(llhREF(1)); SINLAT = sin(llhREF(1));
COSLONG = cos(llhREF(2)); SINLONG = sin(llhREF(2));

R_ENU2ECEF = [-SINLONG -SINLAT*COSLONG COSLAT*COSLONG;...
               COSLONG -SINLAT*SINLONG COSLAT*SINLONG;...
                     0          COSLAT         SINLAT];

local = R_ENU2ECEF'*[XYZ(1); XYZ(2); XYZ(3)];
NED = [local(2) local(1) -local(3)];
