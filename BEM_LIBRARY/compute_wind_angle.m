function phi_rad = compute_wind_angle(a, a_prime, speed_ratio)
% calculates the wind angle at element i in radians.
% inputs:   a - axial induction factor
%           a_prime - angular induction factor
%           speed_ratio - (lambda_r) local speed ratio
% outputs:  phi_rad - apparent wind angle
top = 1 - a;
bot = speed_ratio*(1+a_prime);
phi_rad = atan(top/bot);

end
