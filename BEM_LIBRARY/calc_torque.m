function Q = calc_torque(r, Pt, blades)
% integrate Pt*r using the trapizoid method discussed in class.
% inputs:   r - array of radii (m)
%           Pt - tangential load (N/m)
%           blades - number of blades
% Output:   Q - torque (Nm)

Q = blades * trapz(r, Pt.*r);

end
