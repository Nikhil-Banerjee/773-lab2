function [a, a_prime] = compute_a_and_a_prime(r, R, phi_rad, Cn, Ct, solidity,conf)
% Computes a and a'. Tip loss factor is also calculated.
% inputs:   r - current radius in m
%           R - total radius in m
%           phi_rad - wind angle in radians
%           Cn - normal coefficent
%           Ct - tangential coefficient
%           solidity - solidity
% outputs:  a - axial induction factor, a
%           a_prime - angular induction factor, a'

%global conf;

B = conf.blades;
TIP_LOSSES = conf.tiploss;

% calculate tip loss factor
if TIP_LOSSES == true
    dr = (R-r)/r;

    if dr == 0 % tip of the blade where F=0. To avoid this singular point, we increase dr by 1%
        dr = 0.01;
    end

    f = B*dr/(2*sin(phi_rad));
    if f < 0
        f = 0;
    end

    F = 2/pi*acos(exp(-f));
else
    F = 1;
end

% calculate a and a'
top = solidity * Cn;
bot = 4 * F * sin(phi_rad)^2 + solidity * Cn;
a = top/bot;

top = solidity * Ct;
bot = 4 * F * sin(phi_rad) * cos(phi_rad) - solidity * Ct;
a_prime = top/bot;

end
