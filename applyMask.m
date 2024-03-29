function [usedPRN] = applyMask(inViewPRN, mSatPos, pos, cn0, elevMask, cn0Mask)
% ---------------------------------------------------------------------------------------
% This function applies a mask to the used satellites. The satellites can
% be masked by its elevation or the C/N0 value.
% 
% Input:  
%           usedPRN:    List of PRN of satellites in view
%           mSatPos:    Matrix with the satellites positions
%           pos:        User's position
%           cn0:        C/N0 of the satellites in dB-Hz
%           elevMask:   Elevation mask in degrees
%           cn0Mask:    C/N0 mask in dB-Hz
%
% Output:
%           usedPRN:    List of PRN of satellites after masking
% ---------------------------------------------------------------------------------------
    % C/N0 mask
    cn0MaskedPRN    =   find(cn0 < cn0Mask);
    usedPRN         =   setdiff(inViewPRN, cn0MaskedPRN);

    % Elevation mask
    elevMaskedPRN   =   [];
    for svPRN = inViewPRN
        [el, ~]     =   elevation_azimuth(pos, mSatPos(svPRN, :));
        if rad2deg(el) < elevMask
            elevMaskedPRN = [elevMaskedPRN, svPRN];
        end
    end
    usedPRN         =   setdiff(usedPRN, elevMaskedPRN);
end