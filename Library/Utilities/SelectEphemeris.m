function [vEphemeris] = SelectEphemeris(Ephem,iPRN,iUser_NoS)

%--------------------------------------------------------------------------
% Copyright � ENAC, 2015.
% ENAC : http://www.enac.fr/.
% signav@recherche.enac.fr
%
% This function select the ephemeris set that best fits SV iPRN at time
% iUser_NoS.
% Input Variables
%   1) Ephem        ephemeris recorded data - (Max_Nb_Sat x 27) matrix
%   2) iPRN         SV PRN #
%   3) iUser_Nos    user time (Number of Seconds since GPS date - NoS)
% Output Variables
%   1) vEphemeris   best fitting ephemris data - (1x29) matrix
%--------------------------------------------------------------------------

% Initialize variables
vEphemeris = [];

% Search of recorded ephemeris data corresponding to SV iPRN
PRN_EphemList = []; PRN_EphemList = find(Ephem(:,1)==iPRN);
if isempty(PRN_EphemList)
    fprintf('\nNo navigation data recorded for PRN %d.\n',iPRN);
    return,
else
    % Select the best fitting ephemeris: ephemeris with TOE that is
    % the closest to the user time
    % Initialize best fitting ephemeris vector - 1x29
    vEphemeris =[];
    fMin_dt = []; fMin_dt = Ephem(PRN_EphemList(1),14)-iUser_NoS; % TOE (in NoS) - User time (in NoS)
    jEphem = PRN_EphemList(1);
    if length(PRN_EphemList)>1
        for jList=2:length(PRN_EphemList)
            f_dt = []; f_dt = Ephem(PRN_EphemList(2),14)-iUser_NoS;
            if (f_dt)<0 && (abs(f_dt)<abs(fMin_dt))
                jEphem = PRN_EphemList(jList);
                fMin_dt = f_dt;
            end
        end
    end
    vEphemeris = Ephem(jEphem,:);
end
