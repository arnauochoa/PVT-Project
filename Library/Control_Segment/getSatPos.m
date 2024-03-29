function [satPos] = getSatPos(satEphem, txTime, epochTime)
% ---------------------------------------------------------------------------------------
% This function computes the position of a satellite at a given epoch.
% Algorithm based on "GNSS DATA PROCESSING. Volume I: Fundamentals and
% Algorithms" (ESA TM-23/1)
% 
% Input:  
%           satEphem:   Ephemeris recorded data of given satellite - (1 x 29) vector
%           txTime:     Time of transmission from satellite
%           epochTime:  Time of reception
%
% Output:
%           mSatPos:    Positions of the satellite - (1 x 3) vector
% ---------------------------------------------------------------------------------------
    
    % Constants
    mu      =   3.986005e14;  % [m^3/s^2]  Gravitational constant
    omegaE  =   7.2921151467e-5;     %  [rad/s]   Earth’s angular velocity
    PI      =   3.1415926535898; 
    
    % Ephemeris parameters
    t0e         =   satEphem(13); % Ephemerides reference epoch in seconds of the week
    sqrtA       =   satEphem(16); % Square root of semi-major axis
    ecc         =   satEphem(15); % Eccentricity
    m0          =   satEphem(22); % Mean anomaly at reference epoch 
    omega       =   satEphem(20); % Argument of perigee
    i0          =   satEphem(18); % Inclination at reference epoch
    omega0      =   satEphem(17); % Longitude of ascending node at the beginning of the week
    deltaN      =   satEphem(23); % Mean motion difference
    iDot        =   satEphem(19); % Rate of inclination angle
    omegaDot    =   satEphem(21); % Rate of node’s right ascension
    cUC         =   satEphem(27); % Latitude argument cosine correction
    cUS         =   satEphem(26); % Latitude argument sine correction
    cRC         =   satEphem(25); % Orbital radius cosine correction
    cRS         =   satEphem(24); % Orbital radius sine correction
    cIC         =   satEphem(29); % Inclination cosine correction
    cIS         =   satEphem(28); % Inclination sine correction

    % Compute sat's position
    tK  =   txTime - t0e;

    tK  =   checkTime(tK);

    mK  =   m0 + (sqrt(mu)/sqrtA^3 + deltaN) * tK;
    mK  =   rem(mK + 2*PI, 2*PI);

    eK  =   findEccAnomaly(mK, ecc);

    vK  =   atan2(sqrt(1-ecc^2) * sin(eK), cos(eK) - ecc);

    phi =   omega + vK;
    phi =   rem(phi + 2*PI, 2*PI);

    uK  =   phi                           + cUC * cos(2*phi) + cUS * sin(2*phi);
    rK  =   sqrtA^2 * (1 - ecc * cos(eK)) + cRC * cos(2*phi) + cRS * sin(2*phi);
    iK  =   i0 + iDot * tK                + cIC * cos(2*phi) + cIS * sin(2*phi);

    lambdaK =   omega0 + (omegaDot - omegaE) * tK - omegaE * t0e;
    lambdaK =   rem(lambdaK + 2*PI, 2*PI);

    mR1I    =   rotx(rad2deg(iK));
    mR3L    =   rotz(rad2deg(lambdaK));
    mR3U    =   rotz(rad2deg(uK));
    rVec    =   [rK 0 0].';

    satPos1  =   mR3L * mR1I * mR3U * rVec;
    
    % Take into account earth rotation
    travelTime  =   epochTime - txTime;
    omegaTau    =   omegaE * travelTime;
    
    mR3         =   rotz(-rad2deg(omegaTau));
    satPos      =   mR3 * satPos1;
end

