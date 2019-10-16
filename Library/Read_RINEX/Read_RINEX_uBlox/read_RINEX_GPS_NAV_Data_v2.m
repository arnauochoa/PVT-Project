function [DATA io_flag_data] = read_RINEX_GPS_NAV_Data_v2(fid)
%--------------------------------------------------------------------------
% Author Carl Milner
% Date 29/10/2012
%
% This function reads the RINEX NAV file data body for a GPS receiver
%
% Input Variables
%   fid                     file id
%
% Output variables
%   1) DATA                 Structure of the data body of RINEX NAV file
%   2) io_flag_header       Flag 0 if correctly output or anything else
%                           in the case of failure


%Modification by A.Guilbert 9/12/2013
% COmment the line BLOCK(c).MISC.fit_int = str2num(line(23:41));
%--------------------------------------------------------------------------

% Initialise variables
debug_nav = 0;
num_seconds_day = 86400;
num_seconds_week = 86400*7;
DATA = [];
io_flag_body = 1;
errorflag = 0;
c = 0;

% Read file
line = fgetl(fid); line = deblank(line);

while ((line(1) ~= -1) && (errorflag == 0))
  c = c + 1;

  % EPOCH
  BLOCK(c).SV_ID = str2num(line(1:2));
  toc_year = str2num(line(4:5));
  toc_month = str2num(line(7:8));
  toc_day = str2num(line(10:11));
  toc_hour = str2num(line(13:14));
  toc_min = str2num(line(16:17));
  toc_sec= str2num(line(18:22));

  if ((toc_year >= 80) && (toc_year <= 99))
    year = 1980;
  else
    year = 2000;
  end

  toc_year = toc_year + year;

  [BLOCK(c).EPOCH.GPSTIME.GPS_Week ...
    BLOCK(c).EPOCH.GPSTIME.SoW BLOCK(c).EPOCH.GPSTIME.NoS] = ...
    Gregorian2GPS([toc_year,toc_month,toc_day,toc_hour,toc_min,toc_sec]);

  BLOCK(c).EPOCH.GREGORIAN.toc_year = toc_year;
  BLOCK(c).EPOCH.GREGORIAN.toc_month = toc_month;
  BLOCK(c).EPOCH.GREGORIAN.toc_day = toc_day;
  BLOCK(c).EPOCH.TIME.toc_hour = toc_hour;
  BLOCK(c).EPOCH.TIME.toc_min = toc_min;
  BLOCK(c).EPOCH.TIME.toc_sec = toc_sec;

  BLOCK(c).CLOCK_CORR.af0 = str2num(line(23:41));
  BLOCK(c).CLOCK_CORR.af1 = str2num(line(42:60));
  BLOCK(c).CLOCK_CORR.af2 = str2num(line(61:79));

  % ORBIT
  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    BLOCK(c).EPHEMERIS.IODE = str2num(line(4:22));
    BLOCK(c).EPHEMERIS.CRS = str2num(line(23:41));
    BLOCK(c).EPHEMERIS.Delta_n = str2num(line(42:60));
    BLOCK(c).EPHEMERIS.M0 = str2num(line(61:79));
  end

  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    BLOCK(c).EPHEMERIS.CUC = str2num(line(4:22));
    BLOCK(c).EPHEMERIS.e = str2num(line(23:41));
    BLOCK(c).EPHEMERIS.CUS = str2num(line(42:60));
    BLOCK(c).EPHEMERIS.sqrt_a = str2num(line(61:79));
  end

  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    BLOCK(c).EPHEMERIS.toe_sow = str2num(line(4:22));
    BLOCK(c).EPHEMERIS.CIC = str2num(line(23:41));
    BLOCK(c).EPHEMERIS.Omega0=str2num(line(42:60));
    BLOCK(c).EPHEMERIS.CIS = str2num(line(61:79));
  end

  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    BLOCK(c).EPHEMERIS.i0 = str2num(line(4:22));
    BLOCK(c).EPHEMERIS.CRC = str2num(line(23:41));
    BLOCK(c).EPHEMERIS.omega = str2num(line(42:60));
    BLOCK(c).EPHEMERIS.Omega_dot = str2num(line(61:79));
  end

  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    BLOCK(c).EPHEMERIS.IDOT = str2num(line(4:22));
    BLOCK(c).L2_CHANNEL.L2_codes = str2num(line(23:41));
    BLOCK(c).EPHEMERIS.toe_GPS_week = str2num(line(42:60));
    BLOCK(c).EPHEMERIS.toe_nos = (...
      BLOCK(c).EPHEMERIS.toe_GPS_week*num_seconds_week) + ...
      BLOCK(c).EPHEMERIS.toe_sow;
    if (length(line) >= 79)
      BLOCK(c).L2_CHANNEL.L2P_flag = str2num(line(61:79));
    else
      BLOCK(c).L2_CHANNEL.L2P_flag = 0.0;
    end
  end

  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    if (length(line) >= 22)
      BLOCK(c).QUALITY.SV_URA = str2num(line(4:22));
    else
      BLOCK(c).MISC.SV_URA = 0;
    end
    if (length(line) >= 41)
      BLOCK(c).QUALITY.SV_health = str2num(line(23:41));
    else
      BLOCK(c).MISC.SV_health = 0;
    end
    if (length(line) >= 60)
      BLOCK(c).MISC.TGD = str2num(line(42:60));
    else
      BLOCK(c).MISC.TGD = 0;
    end
    if (length(line) >= 79)
      BLOCK(c).MISC.IODC = str2num(line(61:79));
    else
      BLOCK(c).MISC.IODC = 0;
    end

    BLOCK(c).MISC.BGD_E5a = 0;
    BLOCK(c).MISC.BGD_E5b = 0;
    BLOCK(c).DATA_SOURCES = 0;
  end

  line = fgetl(fid); line = deblank(line);
  if (line(1) == -1)
    errorflag = 1;
  else
    if (length(line) >= 22)
      BLOCK(c).MISC.tom_sow = str2num(line(4:22));
    else
      BLOCK(c).MISC.tom_sow = 0.0;
    end
    % BLOCK(c).MISC.fit_int = str2num(line(23:41));
    %       spare1(c) = str2num(line(42:60));
    %       spare2(c) = str2num(line(61:79));
  end

  % Read end of file
  line = fgetl(fid); if (line(1) ~= -1) line = deblank(line); end
end

if (errorflag == 0)
  DATA = BLOCK;
  io_flag_data = 0;
end

return
