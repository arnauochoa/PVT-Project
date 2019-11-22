function [healthyPRN]  =   checkSatHealth(trackedPRN, mEphem, epochTime)
% ---------------------------------------------------------------------------------------
% This function checks the health of the satellites and returns the PRNs of
% the satellites in a good health.
% 
% Input:  
%           trackedPRN: Vector containing the numbers of the tracked satellites
%           mEphem:     Matrix containing the ephemeris information (numSat x 29)
%           epochTime:  Corrected time of the current epoch as SoW
%           
%
% Output:
%           healthyPRN: Vector containing the numbers of the tracked satellites
% ---------------------------------------------------------------------------------------

    healthyPRN  =   [];
    iSat        =   1;
    
    for svPRN = trackedPRN
        satEphem    =   SelectEphemeris(mEphem, svPRN, epochTime);
        
        if satEphem(2) == 0
            healthyPRN(iSat) = svPRN;  %#ok<AGROW>
            iSat = iSat + 1;
        end
    end
    
end