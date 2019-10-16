function [RINEX_NAV io_flag] = read_RINEX_NAV_v2(filename)
%--------------------------------------------------------------------------
%
% Author Carl Milner
% Date 29/10/2012
%
% This function reads the RINEX NAV file for a GPS receiver
%
% Input variables:
%   filename:               String of the RINEX filename
%
% Output variables
%   1) RINEX_GPS_NAV        Structure of RINEX NAV file
%   2) io_flag              Flag 0 if correctly output or anything else
%                           in the case of failure
%
%--------------------------------------------------------------------------

% Initialise variables
debug_nav = 0;
io_flag = 1;
RINEX_NAV = [];

% Open the file
fid = fopen(filename);
if (fid == -1)
  fprintf(1,'Error opening nav file\n');
  return;
end

% Read the file header
[HEADER io_flag_header] = read_RINEX_GPS_NAV_Header_v2(fid);

if (io_flag_header == 0)
  % Read file data body
  [DATA io_flag_data] = read_RINEX_GPS_NAV_Data_v2(fid);

  if (io_flag_data == 0)
    % If reading successful, store data
    RINEX_NAV.HEADER = HEADER;
    RINEX_NAV.DATA = DATA;
    io_flag = 0;
  else
    if (debug_nav > 0)
      fprintf(1,'Error reading body of nav file\n');
    end
  end
else
  if (debug_nav > 0)
    fprintf(1,'Error reading header of nav file\n');
  end
end

fclose(fid);
return
