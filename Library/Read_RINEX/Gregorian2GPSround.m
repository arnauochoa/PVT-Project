function [GPS_week sow nos] = Gregorian2GPSround(date_time)
%--------------------------------------------------------------------------
% Author Carl Milner 
% Date 30/10/12
%
% This function converts Gregorian date and time into GPS week and seconds
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

% Determine via Julian Date
year = date_time(1);
month = date_time(2);
day = date_time(3);
hour = date_time(4);
min = date_time(5);
sec = date_time(6);

[j, mjd] = Gregorian2Julian(year,month,day,hour,min,sec);
[GPS_week sow nos] = Julian2GPS(j);

% Round times to nearest 0.01s
sow = round(sow*100.0)/100.0;
nos = round(nos*100.0)/100.0;
if (sow >= 604800)
    GPS_week = GPS_week+1;
    sow = sow - 604800;
end

return 
