function [GPS_week sow nos] = Julian2GPS(j)
%--------------------------------------------------------------------------
% Author Carl Milner
% Date 30/10/12
%
% This function converts the julian day into the corresponding GPS week and
% seconds of the week
% GPS standard epoch begins on 6 Jan 1980 which is 2444244.5
% This file implements Hofmann-Wellenhof, GPS - Theory and Practice 5th Ed
%
% Input Variable
%   j:              Julian Date
%
%  Output Variables
%   1) GPS_week     GPS week number
%   2) sow          Seconds of the week
%   3) nos          Number of seconds from standard epoch
%
%--------------------------------------------------------------------------

num_seconds_day = 86400;
num_seconds_week = 86400*7;

% Determine auxiliary variables
a = floor(j + 0.5);
b = a + 1537;
c = floor((b - 122.1)/365.25);
d = floor(365.25*c);
e = floor((b - d)/30.6001);
D = b;
D = D - d;
D = D - floor(30.6001*e);
D = D + rem((j + 0.5),1);

v = floor(j + 0.5);

N = mod(v,7);

GPS_week = floor((j - 2444244.5)/7);

sow = ( N + 1 + rem(D,1))*num_seconds_day;
sow = mod(sow,num_seconds_week);
nos = (GPS_week*num_seconds_week) + sow;

return
