function [Cl, Cd] = interp_coefficients(alpha_rad, pol)
% Calculate Cl and Cd. Note, if alpha is out of range of coeffiecient data,
% the value of Cl and Cd is held constant.
% inputs:   alpha - angle of attack (radians)
%           pol -  aerofoil data 
% outputs:  Cl - coefficient of lift at alpha_rad
%           Cd - coefficient of drag at alpha_rad

alpha_deg = rad2deg(alpha_rad);

if alpha_deg > pol.alpha(end)
    Cl = pol.CL(end);
    Cd = pol.CD(end);
elseif alpha_deg < pol.alpha(1)
    Cl = pol.CL(1);
    Cd = pol.CD(1);
else
    % linear interpolation  (quick)
    % Cl = interp1(pol.alpha,pol.CL,rad2deg(alpha));
    % Cd = interp1(pol.alpha,pol.CD,rad2deg(alpha));
    
    % linear interp. of smoothed data (quicker than func. and smoother than linear)
    Cl = interp1(pol.alpha,pol.CL_smoothed,alpha_deg);
    Cd = interp1(pol.alpha,pol.CD_smoothed,alpha_deg);
end
end
