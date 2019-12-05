function [ionoCorr]    =   findIonoDelay(posLatLng, el, az, epochTime, ionoA, ionoB)
% ---------------------------------------------------------------------------------------
% This function estimates the propagation delay due to the ionosphere by
% using the Klobuchar model.
% 
% Input:  
%           posLatLng:  Position of the user in Latitude, Longitude.
%           el:        	Elevation of the satellite.
%           az:         Azimuth of the satellite.
%           epochTime:  Time of the current epoch.
%           ionoA:      Iono correction a-parameters (Iono_a = [a0,a1,a2,a3]) 
%           ionoB:      Iono correction b-parameters (Iono_b = [b0,b1,b2,b3])
%
% Output:
%           ionoCorr:   Ionospheric delay [s]
% ---------------------------------------------------------------------------------------
    
%% PAY ATTENTION TO ANGLE UNITY --> SEMI CIRCLES

    %% Constants
    rE      =   6.378e6;        %   [m]     Radius of earth
    hIono   =   3.5e5;          %   [m]     Height of ionospheric layer
    latP    =   deg2rad(78.3);  %   [rad]   Latitude of geomagnetic pole
    lngP    =   deg2rad(291);   %   [rad]   Latitude of geomagnetic pole
    daySec  =   86400;          %   [sec]   Second per day

    %% Klobuchar model
    el      = abs(el);
    
    lat     =   posLatLng(1) / pi;
    lng     =   posLatLng(2) / pi;
    az      =   az / pi;
    el      =   el / pi;
    
    % Earth-centered angle
    psi     =   pi/2 - el - asin(rE/(rE+hIono) * cos(el));
    % Latitude of Ionospheric Pierce Point
    latIPP  =   asin(sin(lat)*cos(psi) + cos(lat)*sin(psi)*cos(az));
    % Longitude of Ionospheric Pierce Point
    lngIPP  =   lng + (psi * sin(az))/cos(latIPP);
    % Geomagnetic latitude of IPP
    latGM   =   asin(sin(latIPP)*sin(latP) + cos(latIPP)*cos(latP)*cos(lngIPP-lngP));
    % Local time at IPP
    tIPP    =   daySec/2 * lngIPP/pi + epochTime;
    if      tIPP  >=    daySec,     tIPP = tIPP - daySec;
    elseif  tIPP  <     0,          tIPP = tIPP + daySec;      end
    % Amplitude of ionospheric delay
    aux     =   [1, (latGM/pi), (latGM/pi)^2, (latGM/pi)^3];
    aI      =   sum(ionoA .* aux);
    if aI < 0, aI = 0; end
    % Period of ionospheric delay
    pI      =   sum(ionoB .* aux);
    if pI < 72000, pI = 72000; end
    % Phase of ionospheric delay
    xI      =   2*pi*(tIPP - 50400)/pI;
    % Slant factor
    f       =   (1 - (rE/(rE+hIono) * cos(el))^2)^(-1/2);
    
    % Ionospheric delay
    if xI < pi/2
        ionoCorr    =   (5e-9 + aI * cos(xI)) * f;
    else
        ionoCorr    =   5e-9 * f;
    end
    
end