function [mSatPos] = getSatPos(Ephem, nEpoch)
% ---------------------------------------------------------------------------------------
% This function computes the position of the satellites at a given epoch
% 
% Input:  
%           Ephem:      Ephemeris recorded data - (nSat x 29) matrix
%           nEpoch:     Current epoch
%
% Output:
%           mSatPos:    Positions of the satellites - (nSat x 3) matrix
% ---------------------------------------------------------------------------------------

    [nSat, ~] = size(Ephem);
    
    mSatPos = zeros(nSat, 3);
    
    for iSat = 1:nSat
        % Compute sat's position --> "Introd. to GNSS 7" & "IS-GPS-200" &
        % "ESA GNSS Book p.57"
        
    end
end

