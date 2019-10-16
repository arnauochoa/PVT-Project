function [j, mjd] = Gregorian2Julian(year,month,day,hour,min,sec)
%--------------------------------------------------------------------------
% Author Carl Milner 
% Date 30/10/12
%
% This function converts Gregorian date and time into Julian day and Mean
% Julian Day
% 
% Input Variables
%   1) year    
%   2) month    
%   3) day     
%   4) hour    
%   5) min      
%   6) sec      
% 
% Output Variables
%   1) GPS_week     GPS week number
%   2) sow          Seconds of the week
%   3) nos          Total seconds from GPS standard epoch
% 
%--------------------------------------------------------------------------

% Determine time in hours 
hours_decimel = hour + (min/60) + (sec/3600); 

% Determine m and y
if (month <= 2) 
    y = year - 1; 
    m = month + 12; 
else 
    y = year; 
    m = month; 
end 

j = floor(365.25*y); 
j = j + floor(30.6001*(m + 1));
j = j + day; 
j = j + (hours_decimel/24.0);
j = j + 1720981.5;

mjd = j - 2400000.5;

return
