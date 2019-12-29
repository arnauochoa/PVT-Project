function [delay]    =   findIonoDelay(posLatLng, el, az, epochTime, ionoA, ionoB)
% ---------------------------------------------------------------------------------------
% This function estimates the propagation delay due to the ionosphere by
% using the Klobuchar model.
% 
% Input:  
%           posLatLng:  Position of the user in Latitude, Longitude. [rad]
%           el:        	Elevation of the satellite. [rad]
%           az:         Azimuth of the satellite. [rad]
%           epochTime:  Time of the current epoch. [SoW]
%           ionoA:      Iono correction a-parameters (Iono_a = [a0,a1,a2,a3]) 
%           ionoB:      Iono correction b-parameters (Iono_b = [b0,b1,b2,b3])
%
% Output:
%           ionoCorr:   Ionospheric delay [s]
% ---------------------------------------------------------------------------------------

    c       =   299792458;
    %initialization
	delay   =   zeros(size(el));
    
    %ionospheric parameters
	a0      =   ionoA(1);
	a1      =   ionoA(2);
	a2      =   ionoA(3);
	a3      =   ionoA(4);
	b0      =   ionoB(1);
	b1      =   ionoB(2);
	b2      =   ionoB(3);
	b3      =   ionoB(4);
    
    %elevation from 0 to 90 degrees
	el      =   abs(el);
	
	%conversion to semicircles
	lat     =   posLatLng(1) / 180;
	lon     =   posLatLng(2) / 180;
	az      =   az / 180;
	el      =   el / 180;
	
	f   =   1 + 16*(0.53-el).^3;
	
	psi =   (0.0137 ./ (el+0.11)) - 0.022;
	
	phi =   lat + psi .* cos(az*pi);
	phi(phi > 0.416)  =  0.416;
	phi(phi < -0.416) = -0.416;
	
	lambda = lon + ((psi.*sin(az*pi)) ./ cos(phi*pi));
	
	ro = phi + 0.064*cos((lambda-1.617)*pi);
	
	t = lambda*43200 + epochTime;
	t = mod(t,86400);
	
	a = a0 + a1*ro + a2*ro.^2 + a3*ro.^3;
	a(a < 0) = 0;
	
	p = b0 + b1*ro + b2*ro.^2 + b3*ro.^3;
	p(p < 72000) = 72000;
	
	x = (2*pi*(t-50400)) ./ p;
	
	%ionospheric delay
	index = find(abs(x) < 1.57);
	delay(index,1) = c * f(index) .* (5e-9 + a(index) .* (1 - (x(index).^2)/2 + (x(index).^4)/24));
	
	index = find(abs(x) >= 1.57);
	delay(index,1) = c * f(index) .* 5e-9;
end