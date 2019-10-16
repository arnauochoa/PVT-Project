function [DATA io_flag_data] = read_RINEX_GPS_OBS_Data_v2(fid,HEADER)%,STARTEPOCH, ENDEPOCH)
%--------------------------------------------------------------------------
% Author Carl Milner
% Date 29/10/2012
%
% This function reads the RINEX OBS file data body
%
% Input variables
%   fid                 file id
%
%  Output Variables
%   1) DATA             Structure of Data Body
%   2) io_flag_data     Flag 0 if correctly output or anything else
%                       in the case of failure
%   3) lastEpochRead    for continued reading
%--------------------------------------------------------------------------

% Initialise variables
debug_sat = 0;
debug_obs = 0;
DATA = [];
io_flag_data = 1;
errorflag = 0;
iEpoch = 0;

count_line = 0;

% Begin reading
line = fgetl(fid);
count_line = count_line + 1;
cEpoch = 0;
contRead=1;

while ((line(1) ~= -1) && (errorflag == 0) && (contRead==1))
  line = deblank(line);

  if (isempty(str2num(line(2:3)))==0)
    iEpoch = iEpoch + 1;

    year = str2num(line(2:3));
    month = str2num(line(5:6));
    day = str2num(line(8:9));
    hour = str2num(line(11:12));
    min = str2num(line(14:15));
    sec = str2num(line(16:26));

    if ((year >= 80) & (year <= 99))
      yplus = 1980;
    else
      yplus = 2000;
    end

    year = year + yplus;

    [GPS_week sow nos] = Gregorian2GPSround([year,month,day,hour,min,sec]);

    epochflag = str2num(line(29));

    numSat = str2num(line(30:32));
    if (debug_sat > 0) fprintf(1,'numSat = %d\n',numSat); end
    
    satListString = line(33:end);
    if (debug_sat > 0)
      fprintf(1,'satListString 1 = %s\n',satListString);
    end
    RX_clk_offset = 0;
    if (HEADER.GENERAL.RX_clk_flag~=0)
      RX_clk_offset = str2num(line(69:end));
    end

    % Determines number of rows in the sat list
    numRow = ceil(numSat/12);

    % Read in the sat PRN strings
    for iRow = 2:1:numRow
      line = fgetl(fid); line = deblank(line);
      count_line = count_line + 1;
      ReadSats = numSat - (12*(iRow-1));

      mm = 12;
      if (12 > ReadSats)
        mm = ReadSats;
      end

      iEnd = 32 + (mm*3);
      addSats = line(33:iEnd);

      satListString = strcat(satListString,addSats);
      if (debug_sat > 0)
        fprintf(1,'satListString 2 = %s\n',satListString);
      end
    end

    % Read PRNs from string

    N = floor((length(satListString))/3);
    if (debug_sat > 0) fprintf(1,'N = %d\n',N); end
    PRNstring = [];

    for iI = 1:1:N
      iSta = ((iI-1)*3) + 1;
      iEnd = iSta + 2;
      if (debug_sat > 0)
        fprintf(1,'Counter = %d %d %d\n',iI,iSta,iEnd);
      end
      PRNstring{iI} = satListString(iSta:iEnd);
      if (debug_sat > 0)
        fprintf(1,'Length of PRNstring = %d\n',length(PRNstring));
      end
    end

    % Check the number of satellites matches the given value

    if (numSat ~= length(PRNstring))
      errorflag = 1;
      if (debug_sat > 0)
        fprintf(1,'errorflag = %d\n',errorflag);
      end
      % wrong=wrong+1;

    else
      numSatGPS = 0;
      numSatGLO = 0;
      numSatGAL = 0;
      numSatSBAS = 0;

      cSat = 1;
      clear PRN;

      for iSat = 1:1:numSat
        prn_string = PRNstring{iSat};

        PRN_type(iSat) = prn_string(1);

        if (strcmp(PRN_type(iSat),'G')==1)

          PRN(cSat) = str2num(prn_string(2:end));
          numSatGPS = numSatGPS + 1;
          GPS_PRN(numSatGPS) = PRN(cSat);
          CONSTELL(cSat) = 'G';

          indices(cSat)=iSat;
          cSat=cSat+1;

        elseif (strcmp(PRN_type(iSat),'E'))

          numSatGAL = numSatGAL + 1;

          PRN(cSat) = str2num(prn_string(2:end)) + 60;
          CONSTELL(cSat) = 'E';

          indices(cSat)=iSat;
          cSat=cSat+1;
        elseif (strcmp(PRN_type(iSat),'S'))

          numSatSBAS = numSatSBAS + 1;

          PRN(cSat) = str2num(prn_string(2:end));
          CONSTELL(cSat) = 'S';

          indices(cSat)=iSat;
          cSat=cSat+1;

        elseif (strcmp(PRN_type(iSat),'R'))

          numSatGLO = numSatGLO + 1;

          PRN(cSat) = str2num(prn_string(2:end));
          CONSTELL(cSat) = 'R';

          indices(cSat) = iSat;
          cSat = cSat+1;
        else
          a = 0;
        end

      end

      % Obtain data
      cSat = 0;
      for iSat = 1:1:numSat

        if ((strcmp(PRN_type(iSat),'G')) || ...
            (strcmp(PRN_type(iSat),'R')) || ...
            (strcmp(PRN_type(iSat),'E')) || (strcmp(PRN_type(iSat),'S')))
          cSat = cSat + 1;

          % Read the observables
          iN = HEADER.OBSERVABLES.NumObs;
          if (debug_obs > 0)
            fprintf(1,'iN = %d\n',iN);
          end
          line = fgetl(fid); line = deblank(line);
          count_line = count_line + 1;

          nL = length(line);
          dL = 80-nL;
          line = horzcat(line,blanks(dL));
          v = zeros(1,iN);
          vb = zeros(1,iN);
          vc = zeros(1,iN);
          p = zeros(1,iN);
          pb = zeros(1,iN);
          pc = zeros(1,iN);

          for iMeas = 1:1:4
            m = (iMeas-1)*16;
            temp = sscanf(line(1+m:14+m),'%f');
            tempb = sscanf(line(15+m:15+m),'%f');
            tempc = sscanf(line(16+m:16+m),'%f');
            if (debug_obs > 0)
              fprintf(1,'[temp, tempb, tempc] = [%f, %f, %f]\n',...
                temp,tempb,tempc);
            end
            if (isempty(temp))
              v(iMeas) = 0;
              p(iMeas) = 0;
            else
              v(iMeas) = temp;
              p(iMeas) = 1;
            end

            if (isempty(tempb))
              vb(iMeas) = 0;
              pb(iMeas) = 0;
            else
              vb(iMeas) = tempb;
              pb(iMeas) = 1;
            end

            if (isempty(tempc))
              vc(iMeas) = 0;
              pc(iMeas) = 0;
            else
              vc(iMeas) = tempc;
              pc(iMeas) = 1;
            end

          end
          if (debug_obs > 0) fprintf(1,'\n'); end
          % disp('Premiere boucle iMeas finie');

          if (iN > 5)
            line = fgetl(fid); line = deblank(line);
            count_line = count_line + 1;
            nL = length(line);
            dL = 80-nL;
            line = horzcat(line,blanks(dL));
            nN = 10;
            if (iN < nN)
              nN = iN;
            end

            for iMeas = 6:1:nN
              m = (iMeas-6)*16;
              temp = sscanf(line(1+m:14+m),'%f');
              tempb = sscanf(line(15+m:15+m),'%f');
              tempc = sscanf(line(16+m:16+m),'%f');

              if (isempty(temp))
                v(iMeas) = 0;
                p(iMeas) = 0;
              else
                v(iMeas) = temp;
                p(iMeas) = 1;
              end

              if (isempty(tempb))
                vb(iMeas) = 0;
                pb(iMeas) = 0;
              else
                vb(iMeas) = tempb;
                pb(iMeas) = 1;
              end

              if (isempty(tempc))
                vc(iMeas) = 0;
                pc(iMeas) = 0;
              else
                vc(iMeas) = tempc;
                pc(iMeas) = 1;
              end

            end

            if (iN > 10)
              line = fgetl(fid); line = deblank(line);
              count_line = count_line + 1;
              nL = length(line);
              dL = 80-nL;
              line = horzcat(line,blanks(dL));
              nN = 15;
              if (iN<nN)
                nN  = iN;
              end

              for iMeas = 11:1:nN
                m = (iMeas-11)*16;
                temp = sscanf(line(1+m:14+m),'%f');
                tempb = sscanf(line(15+m:15+m),'%f');
                tempc = sscanf(line(16+m:16+m),'%f');

                if (isempty(temp))
                  v(iMeas) = 0;
                  p(iMeas) = 0;
                else
                  v(iMeas) = temp;
                  p(iMeas) = 1;
                end

                if (isempty(tempb))
                  vb(iMeas) = 0;
                  pb(iMeas) = 0;
                else
                  vb(iMeas) = tempb;
                  pb(iMeas) = 1;
                end

                if (isempty(tempc))
                  vc(iMeas) = 0;
                  pc(iMeas) = 0;
                else
                  vc(iMeas) = tempc;
                  pc(iMeas) = 1;
                end

              end

              if (iN > 15)
                line = fgetl(fid); line = deblank(line);
                count_line = count_line + 1;
                nL = length(line);
                dL = 80-nL;
                line = horzcat(line,blanks(dL));
                nN = 20;
                if (iN < nN)
                  nN = iN;
                end

                for iMeas = 16:1:nN
                  m = (iMeas-16)*16;
                  temp =  sscanf(line(1+m:14+m),'%f');
                  tempb = sscanf(line(15+m:15+m),'%f');
                  tempc = sscanf(line(16+m:16+m),'%f');

                  if (isempty(temp))
                    v(iMeas) = 0;
                    p(iMeas) = 0;
                  else
                    v(iMeas) = temp;
                    p(iMeas) = 1;
                  end

                  if (isempty(tempb))
                    vb(iMeas) = 0;
                    pb(iMeas) = 0;
                  else
                    vb(iMeas) = tempb;
                    pb(iMeas) = 1;
                  end

                  if (isempty(tempc))
                    vc(iMeas) = 0;
                    pc(iMeas) = 0;
                  else
                    vc(iMeas) = tempc;
                    pc(iMeas) = 1;
                  end
                end
              end
            end
          end
          % disp('Deuxième boucle iMeas finie');

          P1 = 0;
          P1_read = 0;
          P2 = 0;
          P2_read = 0;
          S1 = 0;
          S1_read = 0;
          L1 = 0;
          L1_read = 0;
          L2 = 0;
          L2_read = 0;
          S2 = 0;
          S2_read = 0;
          CA = 0;
          CA_read = 0;
          LA = 0;
          LA_read = 0;
          SA = 0;
          SA_read = 0;
          CC = 0;
          CC_read = 0;
          LC = 0;
          LC_read = 0;
          SC = 0;
          SC_read = 0;
          CD = 0;
          CD_read = 0;
          LD = 0;
          LD_read = 0;
          SD = 0;
          SD_read = 0;
          C1 = 0;
          C1_read = 0;
          C5 = 0;
          C5_read = 0;
          L5 = 0;
          L5_read = 0;
          S5 = 0;
          S5_read = 0;
          D1 = 0;
          D1_read = 0;
          D2 =0;
          D2_read = 0;

          for iMeas = 1:1:iN

            ObsType = HEADER.OBSERVABLES.ObsTypes{iMeas};
            switch ObsType
              case 'P1'
                P1 = v(iMeas);
                P1_read = p(iMeas);
              case 'L1'
                L1 = v(iMeas);
                L1_read = p(iMeas);
              case 'S1'
                S1 = v(iMeas);
                S1_read = p(iMeas);
              case 'P2'
                P2 = v(iMeas);
                P2_read = p(iMeas);
              case 'L2'
                L2 = v(iMeas);
                L2_read = p(iMeas);
              case 'S2'
                S2 = v(iMeas);
                S2_read = p(iMeas);
              case 'CA'
                CA = v(iMeas);
                CA_read = p(iMeas);
              case 'LA'
                LA = v(iMeas);
                LA_read = p(iMeas);
              case 'SA'
                SA = v(iMeas);
                SA_read = p(iMeas);
              case 'CC'
                CC = v(iMeas);
                CC_read = p(iMeas);
              case 'LC'
                LC = v(iMeas);
                LC_read = p(iMeas);
              case 'SC'
                SC = v(iMeas);
                SC_read = p(iMeas);
              case 'CD'
                CD = v(iMeas);
                CD_read = p(iMeas);
              case 'LD'
                LD = v(iMeas);
                LD_read = p(iMeas);
              case 'SD'
                SD = v(iMeas);
                SD_read = p(iMeas);
              case 'C1'
                C1 = v(iMeas);
                C1_read = p(iMeas);
              case 'C5'
                C5 = v(iMeas);
                C5_read = p(iMeas);
              case 'L5'
                L5 = v(iMeas);
                L5_read = p(iMeas);
              case 'S5'
                S5 = v(iMeas);
                S5_read = p(iMeas);
              case 'D1'
                D1 = v(iMeas);
                D1_read = p(iMeas);
              case 'D2'
                D2 = v(iMeas);
                D2_read = p(iMeas);
                % case 'S1'
                % S1 = v(j);
                % S1_read = p(j);
                % case 'S2'
                % S2 = v(j);
                % S1_read = p(j);
            end

          end

          % if ((C1_PR<1e8) && (C1_PR>1e6))
          % if ((P2_PR<4e7) && (P2_PR>1e7))
          % (strcmp(OPTIONS.RX_SFDF,'SF')) ||

          OBS(cSat).P1 = P1;
          OBS(cSat).L1 = L1;
          OBS(cSat).S1 = S1;
          OBS(cSat).P2 = P2;
          OBS(cSat).L2 = L2;
          OBS(cSat).S2 = S2;
          OBS(cSat).CA = CA;
          OBS(cSat).LA = LA;
          OBS(cSat).SA = SA;
          OBS(cSat).CC = CC;
          OBS(cSat).LC = LC;
          OBS(cSat).SC = SC;
          OBS(cSat).CD = CD;
          OBS(cSat).LD = LD;
          OBS(cSat).SD = SD;
          OBS(cSat).C1 = C1;
          OBS(cSat).C5 = C5;
          OBS(cSat).L5 = L5;
          OBS(cSat).S5 = S5;
          OBS(cSat).D1 = D1;
          OBS(cSat).D2 = D2;

          OBS(cSat).P1_read = P1_read;
          OBS(cSat).L1_read = L1_read;
          OBS(cSat).S1_read = S1_read;
          OBS(cSat).P2_read = P2_read;
          OBS(cSat).L2_read = L2_read;
          OBS(cSat).S2_read = S2_read;
          OBS(cSat).CA_read = CA_read;
          OBS(cSat).LA_read = LA_read;
          OBS(cSat).SA_read = SA_read;
          OBS(cSat).CC_read = CC_read;
          OBS(cSat).LC_read = LC_read;
          OBS(cSat).SC_read = SC_read;
          OBS(cSat).CD_read = CD_read;
          OBS(cSat).LD_read = LD_read;
          OBS(cSat).SD_read = SD_read;
          OBS(cSat).C1_read = C1_read;
          OBS(cSat).C5_read = C5_read;
          OBS(cSat).L5_read = L5_read;
          OBS(cSat).S5_read = S5_read;
          OBS(cSat).D1_read = D1_read;
          OBS(cSat).D2_read = D2_read;
          % end
          % else
          %   PRN(cSat)=[];
          %   CONSTELL(cSat) =[];
          %   cSat = cSat - 1;
          % end

        else
          % Other GNSS to be added...
          line = fgetl(fid); line = deblank(line);
          count_line = count_line + 1;
        end
      end

      % contRead = 0;
      EPOCH.GREGORIAN.year = year;
      EPOCH.GREGORIAN.month = month;
      EPOCH.GREGORIAN.day = day;
      EPOCH.TIME.hour = hour;
      EPOCH.TIME.min = min;
      EPOCH.TIME.sec = sec;
      EPOCH.GPSTIME.GPS_Week = GPS_week;
      EPOCH.GPSTIME.SoW = sow;
      EPOCH.GPSTIME.NoS = nos;
      EPOCH.epochflag = epochflag;

      EPOCH.RX_clk_offset = RX_clk_offset;
      cEpoch = cEpoch + 1;
      DATA(cEpoch).EPOCH = EPOCH;

      % Select constellations of interest
      CONSTELL_REF = CONSTELL;
      c2sat = 1;
      for iSat = 1:cSat
        if((CONSTELL_REF(iSat)=='G') ||  (CONSTELL_REF(iSat)=='F'))
          c2sat = c2sat+1;
        elseif((CONSTELL_REF(iSat)~='G') &&  (CONSTELL_REF(iSat)~='F'))
          PRN(c2sat) = [];
          CONSTELL(c2sat) = [];
          OBS(c2sat) = [];
        end
      end
      DATA(cEpoch).PRNs = PRN;
      DATA(cEpoch).CONSTELL = CONSTELL;
      DATA(cEpoch).OBS = OBS;
      EPOCH.numSat = c2sat-1;

      io_flag_data = 0;

      clear EPOCH PRN OBS;
    end

    % Read next line
    line = fgetl(fid); % line = deblank(line);
  end
end

if (debug_sat > 0) fprintf(1,'iEpoch = %d\n',iEpoch); end

end
