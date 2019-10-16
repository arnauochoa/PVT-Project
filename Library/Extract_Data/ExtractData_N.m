function [Iono_a, Iono_b, Ephem]=ExtractData_N(HEADER_N, DATA_N)

%--------------------------------------------------------------------------
% Copyright � ENAC, 2015.
% ENAC : http://www.enac.fr/.
% signav@recherche.enac.fr
%
% This functions extract the ephemeris data after reading the RINEX file
% .nav
% Input Variables
%   1) HEADER_N    cell containing .nav file header
%   2) DATA_N      cell containing .nav file recorded data
%       DATA_N(j).*      jth satellite data
% Output Variables
%   1) Iono_a      Iono correction a-parameters (Iono_a = [a0,a1,a2,a3])
%   2) Iono_b      Iono correction b-parameters (Iono_b = [b0,b1,b2,b3])
%   3) Ephem       Ephemeris recorded data - (Max_Nb_Sat x 29) matrix
%       Ephem(j,:)      jth SV data
%       Ephem(j,1) = SV PRN number
%       Ephem(j,2) = SV health
%       Ephem(j,3) = Epoch Toc - Time of Clock (week #)
%       Ephem(j,4) = Epoch Toc - Time of Clock (second of week)
%       Ephem(j,5) = Epoch Toc - Time of Clock (number of seconds since GPS date  - NoS)
%       Ephem(j,6) = SV clock bias (af0)
%       Ephem(j,7) = SV clock drift (af1)
%       Ephem(j,8) = SV clock drift rate (af2)
%       Ephem(j,9) = TGD
%       Ephem(j,10) = IODE Issue of Data Ephemeris
%       Ephem(j,11) = IODC Issue of Data, Clock
%       Ephem(j,12) = Toe Time of ephemeris (GPS Week #)
%       Ephem(j,13) = Toe Time of ephemeris (second of week)
%       Ephem(j,14) = Toe Time of ephemeris (number of seconds since GPS date - NoS)
%       Ephem(j,15) = e Eccentricity
%       Ephem(j,16) = sqrt(A) Square Root of the Semi-Major Axis
%       Ephem(j,17) = (OMEGA)0 Longitude of ascending node of orbital plane
%       at weekly epoch
%       Ephem(j,18) = i0 Inclination angle at reference time
%       Ephem(j,19) = IDOT
%       Ephem(j,20) = omega Argument of perigee
%       Ephem(j,21) = OMEGA DOT Rate of right ascension
%       Ephem(j,22) = M0
%       Ephem(j,23) = Delta_n
%       Ephem(j,24) = Crs
%       Ephem(j,25) = Crc
%       Ephem(j,26) = Cus
%       Ephem(j,27) = Cuc
%       Ephem(j,28) = Cis
%       Ephem(j,29) = Cic
%--------------------------------------------------------------------------

% Initialize Variables
Iono_a = [];
Iono_b = [];
Ephem = [];

% Extract iono correction parameters
Iono_a = [HEADER_N.IONO.a0, HEADER_N.IONO.a1, HEADER_N.IONO.a2, HEADER_N.IONO.a3];
Iono_b = [HEADER_N.IONO.b0, HEADER_N.IONO.b1, HEADER_N.IONO.b2, HEADER_N.IONO.b3];

% Number of sets of ephemeris data
EphemSet_Nb = 0; EphemSet_Nb = length(DATA_N);

% Extract ephemeris recorded data
Ephem=zeros(EphemSet_Nb,27);

for j=1:EphemSet_Nb, % For each set of ephemeris   
    
    Ephem(j,1) = DATA_N(j).SV_ID;
    Ephem(j,2) = DATA_N(j).QUALITY.SV_health;
    Ephem(j,3) = DATA_N(j).EPOCH.GPSTIME.GPS_Week;
    Ephem(j,4) = DATA_N(j).EPOCH.GPSTIME.SoW;
    Ephem(j,5) = DATA_N(j).EPOCH.GPSTIME.NoS;
    Ephem(j,6) = DATA_N(j).CLOCK_CORR.af0;
    Ephem(j,7) = DATA_N(j).CLOCK_CORR.af1;
    Ephem(j,8) = DATA_N(j).CLOCK_CORR.af2;
    Ephem(j,9) = DATA_N(j).MISC.TGD;
    Ephem(j,10) = DATA_N(j).EPHEMERIS.IODE;
    Ephem(j,11) = DATA_N(j).MISC.IODC;
    Ephem(j,12) = DATA_N(j).EPHEMERIS.toe_GPS_week;
    Ephem(j,13) = DATA_N(j).EPHEMERIS.toe_sow;
    Ephem(j,14) = DATA_N(j).EPHEMERIS.toe_nos;
    Ephem(j,15) = DATA_N(j).EPHEMERIS.e;
    Ephem(j,16) = DATA_N(j).EPHEMERIS.sqrt_a;
    Ephem(j,17) = DATA_N(j).EPHEMERIS.Omega0;
    Ephem(j,18) = DATA_N(j).EPHEMERIS.i0;
    Ephem(j,19) = DATA_N(j).EPHEMERIS.IDOT;
    Ephem(j,20) = DATA_N(j).EPHEMERIS.omega;
    Ephem(j,21) = DATA_N(j).EPHEMERIS.Omega_dot;
    Ephem(j,22) = DATA_N(j).EPHEMERIS.M0;
    Ephem(j,23) = DATA_N(j).EPHEMERIS.Delta_n;
    Ephem(j,24) = DATA_N(j).EPHEMERIS.CRS;
    Ephem(j,25) = DATA_N(j).EPHEMERIS.CRC;
    Ephem(j,26) = DATA_N(j).EPHEMERIS.CUS;
    Ephem(j,27) = DATA_N(j).EPHEMERIS.CUC;
    Ephem(j,28) = DATA_N(j).EPHEMERIS.CIS;
    Ephem(j,29) = DATA_N(j).EPHEMERIS.CIC;    
    
end
    







