function Pt = tangential_load(a, phi, Ct, chord, vel, conf)
% Calculates the tangential load on the blade
% inputs:   a - axial induction factor (-)
%           phi - apparent wind angle (radians)
%           Ct - tangential coefficient (-)
%           chord - chord length at a given radius (m)
%           vel - inflow wind velocity (m/s)
% outputs:  Pt - tangential load (N/m)

%global conf;

Pt = 0.5 * conf.rho * vel^2 * (1-a)^2 * Ct * chord / sin(phi)^2;

end
