function [HEADER io_flag_header] = read_RINEX_GPS_OBS_Header(fid)
%--------------------------------------------------------------------------
% Author Carl Milner
% Date 29/10/2012
%
% This function reads the RINEX OBS file for a GPS receiver
%
% Input variables
%   fid                 file id
%
%  Output Variables
%   1) HEADER           Structure of Header
%   2) io_flag_header   Flag 0 if correctly output or anything else
%                       in the case of failure
%
%--------------------------------------------------------------------------


%initialise variables
debug_read_obs = 0;
io_flag_header = 1;

line = fgetl(fid);
lineend = line(61:end); lineend = deblank(lineend);
numObsSet = 0;

while ((~strcmp(lineend,'END OF HEADER')) && (line(1) ~= -1))
  HEADER.GENERAL.RX_clk_flag = 0;

  switch (lineend)
    case 'RINEX VERSION / TYPE'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      HEADER.GENERAL.RINEX_Version = str2num(line(1:9));
      HEADER.GENERAL.File_Type = line(21:40);
      HEADER.GENERAL.GNSS = line(41:60);

    case 'PGM / RUN BY / DATE'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      HEADER.GENERAL.Org = line(21:40);

    case 'MARKER NAME'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      HEADER.GENERAL.Marker_Name = line(1:20);

    case 'RCV CLOCK OFFS APPL'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      HEADER.GENERAL.RX_clk_flag = str2num(line(1:6));

    case 'APPROX POSITION XYZ'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      v = sscanf(line(1:60),'%f %f %f');

      HEADER.ANTENNA.POSITION.x_ECEF = v(1);
      HEADER.ANTENNA.POSITION.y_ECEF = v(2);
      HEADER.ANTENNA.POSITION.z_ECEF = v(3);

    case 'ANTENNA: DELTA H/E/N'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      v= sscanf(line(1:60),'%f %f %f');

      HEADER.ANTENNA.CORRECTIONS.up = v(1);
      HEADER.ANTENNA.CORRECTIONS.east = v(2);
      HEADER.ANTENNA.CORRECTIONS.north = v(3);


    case 'WAVELENGTH FACT L1/2'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      v = sscanf(line(1:60),'%f %f %f');

      HEADER.WAVELENGTH_FACTORS.L1 =  v(1);
      HEADER.WAVELENGTH_FACTORS.L2 =  v(2);

    case '# / TYPES OF OBSERV'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      num = str2double(line(1:6));

      if (numObsSet==0)
        HEADER.OBSERVABLES.NumObs = num;
        numObsSet=1;
      end

      for i = 1:1:min(num,9)

        iSta = (6*i) + 5;
        iEnd = (6*(i + 1));

        HEADER.OBSERVABLES.ObsTypes{i} = line(iSta:iEnd);

      end

      if (num > 9)

        line = fgetl(fid);

        for i = 1:1:(num - 9)

          iSta = (6*i) + 5;
          iEnd = (6*(i + 1));

          HEADER.OBSERVABLES.ObsTypes{i + 9} = line(iSta:iEnd);

        end

        if (num > 18)

          line = fgetl(fid);

          for i = 1:1:(num - 18)

            iSta = (6*i) + 5;
            iEnd = (6*(i + 1));

            HEADER.OBSERVABLES.ObsTypes{i + 18} = line(iSta:iEnd);

          end

        end

      end

    case 'INTERVAL'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      HEADER.OBSERVABLES.ObsInt = str2num(line(1:10));

    case 'TIME OF FIRST OBS'
      if (debug_read_obs > 0)
        fprintf(1,'%s\n',lineend);
      end
      HEADER.OBSERVABLES.TimeSys = line(49:51);

      v = sscanf(line(1:57),'%f %f %f %f %f %f');

      year = v(1);
      month = v(2);
      day = v(3);
      hour = v(4);
      minute = v(5);
      sec = v(6);

      [GPS_week sow nos] = Gregorian2GPS([year,month,day,hour,minute,sec]);

      HEADER.OBSERVABLES.FIRST_EPOCH.GREGORIAN.year = year;
      HEADER.OBSERVABLES.FIRST_EPOCH.GREGORIAN.month =month;
      HEADER.OBSERVABLES.FIRST_EPOCH.GREGORIAN.day = day;
      HEADER.OBSERVABLES.FIRST_EPOCH.TIME.hour = hour;
      HEADER.OBSERVABLES.FIRST_EPOCH.TIME.min = minute;
      HEADER.OBSERVABLES.FIRST_EPOCH.TIME.sec = sec;
      HEADER.OBSERVABLES.FIRST_EPOCH.GPSTIME.GPS_Week = GPS_week;
      HEADER.OBSERVABLES.FIRST_EPOCH.GPSTIME.SoW = sow;
      HEADER.OBSERVABLES.FIRST_EPOCH.GPSTIME.NoS = nos;

  end

  % Read next line
  line = fgetl(fid);
  lineend = line(61:end); lineend = deblank(lineend);
end

% Check file read correctly
if (line(1) ~= -1)
  io_flag_header = 0;
else
  if (debug_read_obs > 0)
    fprintf(1,'File not read correctly\n');
  end
end

return
