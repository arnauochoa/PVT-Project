function [HEADER io_flag_header] = read_RINEX_GPS_NAV_Header_v2(fid)
%--------------------------------------------------------------------------
% Author Carl Milner
% Date 29/10/2012
%
% This file reads the RINEX NAV file header block
%
% Input variables
%   fid                 file id
%
%  Output Variables
%   1) HEADER           Structure of Header
%   2) io_flag_header   Flag 0 if correctly output or anything else
%                       in the case of failure
%--------------------------------------------------------------------------

debug_nav = 0;
io_flag_header = 1;

line = fgetl(fid);
lineend = line(61:end); lineend = deblank(lineend);

while ((~strcmp(lineend,'END OF HEADER')) && (line(1) ~= -1))
  
  if (debug_nav == 1) fprintf(1,'lineend = %s\n',lineend); end
  
  switch (lineend)
    case 'RINEX VERSION / TYPE'
      HEADER.GENERAL.RINEX_Version = str2double(line(1:9));
      HEADER.GENERAL.File_Type = line(21:40);
    case 'ION ALPHA'
      HEADER.IONO.a0 = str2num(line(3:14));
      HEADER.IONO.a1 = str2num(line(15:26));
      HEADER.IONO.a2 = str2num(line(27:38));
      HEADER.IONO.a3 = str2num(line(39:50));
    case 'ION BETA'
      HEADER.IONO.b0 = str2num(line(3:14));
      HEADER.IONO.b1 = str2num(line(15:26));
      HEADER.IONO.b2 = str2num(line(27:38));
      HEADER.IONO.b3 = str2num(line(39:50));
    case 'DELTA-UTC: A0,A1,T,W'
      HEADER.UTC.A0 = str2num(line(4:22));
      HEADER.UTC.A1 = str2num(line(23:41));
      HEADER.UTC.T = str2num(line(42:50));
      HEADER.UTC.W = str2num(line(51:59));
    case 'LEAP SECONDS'
      HEADER.LEAP_SECONDS.DT = str2num(line(1:6));
  end

  % Read a new line
  line = fgetl(fid);
  lineend = line(61:end); lineend = deblank(lineend);
end

if (line(1) ~= -1)
  io_flag_header = 0;
end

return
