%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NED = f_xyz_2_NED_A(XYZw, XYZ0)                                           %
%                                                                           %
% Conversion des coordonnees d'un vecteur exprimees dans le WGS84 en un     %
% vecteur dans le repere local NED. Formule de [Salychev]                   %
%                                                                           %
% Entr�es : - XYZw : vecteur ligne devant etre converti, exprim� en         %
%             rectangulaire dans le WGS-84                                  %
%           - XYZ0 : position de l'origine du rep�re local, exprim� en      %
%             rectangulaire dans le WGS-84 (vecteur ligne)                  %
%                                                                           %
% Sortie :  - local : vecteur contenant le coordonn�es de XYZw dans le      %
%             rep�re local (Nord (m), East (m), Bas (m))                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NED = f_xyz_2_NED_A(XYZw, XYZ0)

XYZ = XYZw - XYZ0;            % R�cup�ration du vecteur "centre du rep�re local -> satellite"
llhREF = f_xyz_2_llh(XYZ0); % R�cup�ration des coordon�es llh caract�risant l'originie du rep�re local

% D�finition de la matrice de changement de rep�re WGS-84->local
COSLAT = cos(llhREF(1)); SINLAT = sin(llhREF(1));
COSLONG = cos(llhREF(2)); SINLONG = sin(llhREF(2));

R_ENU2ECEF = [-SINLONG -SINLAT*COSLONG COSLAT*COSLONG;...
               COSLONG -SINLAT*SINLONG COSLAT*SINLONG;...
                     0          COSLAT         SINLAT];

local = R_ENU2ECEF'*[XYZ(1); XYZ(2); XYZ(3)];
NED = [local(2) local(1) -local(3)];
