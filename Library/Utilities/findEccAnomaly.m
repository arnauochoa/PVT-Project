function [eK] = findEccAnomaly(mK, ecc)
% ---------------------------------------------------------------------------------------
% This function computes the eccentricity anomaly from the eccentricity and
% the mean anomaly at reference epoch.
% 
% Input:  
%           mK:         Mean anomaly at reference epoch.
%           ecc:        Eccentricity
%
% Output:
%           eK:         Eccentricity anomaly
% ---------------------------------------------------------------------------------------

    % Iterative solution of Mk = Ek + e*sin(Ek)
    dE  =   Inf;
    eK  =   mK;
    i   =   1;
    while abs(dE) > 1e-12 && i < 10
        oldEk   =   eK;
        eK      =   mK + ecc*sin(eK);
        dE      =   rem(eK-oldEk, 2*pi); %repeat this for the rest
        i       =   i+1;
    end
    eK  =   rem(eK + 2*pi, 2*pi);

end