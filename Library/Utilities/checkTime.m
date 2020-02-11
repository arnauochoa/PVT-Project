function [time] = checkTime(time)
% ---------------------------------------------------------------------------------------
% This function repairs over- and underflow of GPS time
% 
% Input:  
%           time:           Time to check.
% Output:
%           checkedTime:    Time checked and corrected if necessary.
% ---------------------------------------------------------------------------------------

    weekSec     =    604800;
    
    if      time  >   weekSec/2,      time = time - weekSec;
    elseif  time  <  -weekSec/2,      time = time + weekSec;      end
    
end