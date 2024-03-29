function [w] = getWeight(elevation, cn0, type)
% ---------------------------------------------------------------------------------------
% This function computes the weight related to a satellite. Different types
% of weightings can be chosen. See comments to find sources.
% Thanks to Vicente Lucas (UAB-SPCOMNAV)!!!
% 
% Input:  
%           elevation:  Elevation of the satellite in radians.
%           cn0:        C/N0 of the satellite in dB-Hz
%           type:       Type of weighting (1 to 5)
%
% Output:
%           w:        	Weight given to the satellite
% ---------------------------------------------------------------------------------------
    switch(type)
        case 0
            % No weighting
            w = 1;
        case 1
            % Sinusoidal weighting method [Rahemi, N., et al. "Accurate solution of navigation 
            % equations in GPS receivers for very high velocities using pseudorange measurements."]
            w   =   1./sin(elevation * pi/180).^2;
        case 2
            w   =   1./tan(elevation * pi/180-0.1).^2;                    
            % Tangential weighting method [Rahemi, N., et al. "Accurate solution of navigation 
            % equations in GPS receivers for very high velocities using pseudorange measurements."]
        case 3
            w   =   0.244*10.^(-0.1*cn0);                         
            % C/N0 weighting method - Sigma e [Wieser, Andreas, et al. "An extended weight 
            % model for GPS phase observations"]
        case 4
            w   =   1*(10.^(-0.1*cn0))./sin(elevation * pi/180).^2;    
            % C/N0+sinusoidal weighting method [Tay, Sarab, et al. "Weighting models for 
            % GPS Pseudorange observations for land transportation in urban canyons"]
        case 5
            w   =   1*(10.^(-0.1*cn0))./tan(elevation * pi/180).^2;
            % C/N0+tangential weighting method [Inspired by Satab Tay, et al. paper]
        otherwise
            error('The selected weighting method is not available')
    end
    w = 1/w;
end