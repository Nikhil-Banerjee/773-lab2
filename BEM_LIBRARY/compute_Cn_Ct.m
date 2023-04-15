function [Cn, Ct] = compute_Cn_Ct(phi, Cl, Cd)
% Computes Cn and Ct
% inputs:   phi - wind angle in radians
%           Cl - coefficient of lift
%           Cd - coefficient of drag
% outputs:  Cn - normal coefficient
%           Ct - tangential coefficient

Cn = Cl * cos(phi) + Cd * sin(phi);
Ct = Cl * sin(phi) - Cd * cos(phi);

end
