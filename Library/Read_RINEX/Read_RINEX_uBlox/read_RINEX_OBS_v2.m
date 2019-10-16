function [OBS io_flag] = read_RINEX_OBS_v2(filename)
%--------------------------------------------------------------------------
% Author Carl Milner
% Date 29/10/2012
%
% This function reads the RINEX OBS file for a GPS receiver
%
% Input variables:
%   filename:               String of the RINEX filename
%
% Output variables
%   1) RINEX_OBS            Structure of RINEX OBS file
%   2) io_flag              Flag 0 if correctly output or anything else
%                           in the case of failure
%--------------------------------------------------------------------------

% Initialise variables
debug_read_obs = 1;
io_flag = 1;
OBS = [];

% Open file
fid = fopen(filename);
if (fid == -1)
  fprintf(1,'Error opening obs file\n');
  return;
end

% Read RINEX OBS header
[HEADER io_flag_header] = read_RINEX_GPS_OBS_Header(fid);

% If header read continue
if (io_flag_header == 0)
  [DATA io_flag_data] = read_RINEX_GPS_OBS_Data_v2(fid,HEADER);
  if (io_flag_data == 0)
    % Store data in structures
    OBS.HEADER = HEADER;
    OBS.DATA = DATA;
    io_flag = 0;
  else
    if (debug_read_obs > 0)
      fprintf(1,'Error reading body of obs file\n');
    end
  end
else
  if (debug_read_obs > 0)
    fprintf(1,'Error reading header of obs file\n');
  end
end

fclose(fid);

return
