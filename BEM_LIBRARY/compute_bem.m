function [Q, design_out] = compute_bem(rpm, vel, design, warnings, conf, varargin)
% BEM proceedure for a given aerofiol design.
% inputs:   rpm - rotations per minute
%           vel - upstream wind velocity (m/s)
%           design - data structure describing turbine design
%               beta - array of setting angles (deg.)
%               chord - array of chord lengths (m)
%               r - array of radii (m)
%               blades - number of blades (int)
%               aerofoils - array of aerofoils shape names
%           pol - data structure describing aerofoil lift and drag
%               CL - array of coefficient of lift
%               CD - array of coefficient of drag
%           warnings - print additional convergence warnings to terminal
% outputs:  Q - torque produced by turbine at given rpm and inflow vel (Nm)
%           design_out - turbine design (same as design, with a few added pars listed below)
%               alpha - array of calculated attack angles for each element (deg.)
%               phi - array of apparent wind angle for each element (deg.)
%               a - array of calculated axial induction factors
%               a_prime - array of calculated angular induction factors
%               solidity - array of solidity at each radius

%global conf;

if conf.verbose > 0,
    disp(['Starting RPM = ', num2str(rpm), ', wind speed = ', num2str(vel)])
    disp(design)
end

a_guess = 1/3;
a_prime_guess = 0;
a_new = 0;
a_prime_new =  0;
phi = 0;
Ct = 0;

omega = rpm * conf.RPM2RADS;

NEL = length(design.r);
R = design.r(end);
a = zeros(1,NEL);
a_prime = zeros(1,NEL);
alpha = zeros(1,NEL);
phi = zeros(1,NEL);
Pt = zeros(1,NEL);
unconv_tols = zeros(1,NEL);
unconv_count = 0;

%iterate over blade elements starting at the tip and ending at the hub
for i = NEL:-1:1

    if conf.verbose > 4, fprintf("Calculating blade element %d\n",i), end

    j = 1;
    r = design.r(i);
    beta = deg2rad(design.beta(i));
    solidity = design.blades*design.chord(i)/(2*pi*r);
    speed_ratio = omega*r/vel;
    converged = false;
%    disp(design.aerofoils(i))
    pol = conf.afData(design.aerofoils(i));
    
    % iterate to find a and a' 
    while converged == false
        phi = compute_wind_angle(a_guess,a_prime_guess,speed_ratio);
        alpha = phi - beta;

        [Cl, Cd] = interp_coefficients(alpha, pol);

        [Cn, Ct] = compute_Cn_Ct(phi, Cl, Cd);

        [a_new, a_prime_new] = compute_a_and_a_prime(r, R, phi, Cn, Ct, solidity,conf);


        if abs((a_new - a_guess) / a_guess) < 0.001 && j > 2      % if solution converged (only use a as criteria of convergence)
            converged = true;
            if conf.verbose > 4, fprintf("Element %d converged after %d iters with obj. value of %.5f\n",i,j,abs(a_new - a_guess) / a_guess), end
        end

        convergence_par = 0.25;
        if j > 10 && j <= 20
            if j == 11
                if conf.verbose > 4, fprintf("Warning: slow convergence for element %d: changed convergence par to 0.15\n",i), end
            end
            convergence_par = 0.15;
        elseif j > 20 && j <= 30
            if j == 21
                if conf.verbose > 4, fprintf("Warning: slow convergence for element %d: changed convergence par to 0.1\n",i), end
            end
            convergence_par = 0.1;
        elseif j> 30 && j <= 40
            if j == 31
                if conf.verbose > 4, fprintf("Warning: slow convergence for element %d: changed convergence par to 0.05\n",i), end
            end
            convergence_par = 0.05;
        elseif j > 40
            if conf.verbose > 4, fprintf("WARNING: Element %d unconverged after %d iters with obj. value of %.5f\n",i,j,abs(a_new - a_guess) / a_guess), end
            unconv_count = unconv_count + 1;
            unconv_tols(i) = abs((a_new - a_guess) / a_guess);
            % Ensure values of a and a' are within physical bounds if they do not converge
            if a_new > 0.5; a_new = 0.5; end 
            if a_prime_new < 0; a_prime_new = 0.01; end
            break
        end
        
        % slow convergence down to avoid oscillations in the value of a
        da = a_new - a_guess;
        a_guess = a_guess + da * convergence_par;               

        if a_guess > 0.5
            a_guess = 0.5;
        elseif a_guess < 0
            a_guess = 0.01;
        end
        
        % slow convergence down to avoid oscillations in the value of a'
        da_p = a_prime_new - a_prime_guess;
        a_prime_guess = a_prime_guess + da_p*convergence_par;   

        if a_prime_guess < 0
            a_prime_guess = 0.01;
        end

        j = j + 1;
    end

    % calculate and store final parameters for the blade element
    PHI(i) = compute_wind_angle(a_new,a_prime_new,speed_ratio);
    ALPHA(i) = PHI(i) - beta;
    [Cl, Cd] = interp_coefficients(ALPHA(i),pol);
    Ct = Cl * sin(PHI(i)) - Cd * cos(PHI(i));
    Pt(i) = tangential_load(a_new, PHI(i), Ct, design.chord(i), vel, conf);
    A(i) = a_new;
    A_PRIME(i) =  a_prime_new;
    SOL(i) = solidity;

end

% Sometimes blade elements dont converge
if unconv_count > 0 && warnings == true
    [M, I] = max(unconv_tols);
    fprintf("Warning: %d element(s) did not converge to desired tol. for Vu = %.2f m/s, RPM = %d Max tol. = %.4f at el. %d\n", ...
        unconv_count,vel,rpm, M,I)
end

% Store and return design parameters
Q = calc_torque(design.r, Pt, design.blades);
design_out.alpha = rad2deg(ALPHA);
design_out.phi = rad2deg(PHI);
design_out.beta = design.beta;
design_out.r = design.r;
design_out.chord = design.chord;
design_out.a = A;
design_out.a_prime = A_PRIME;
design_out.solidity = SOL;
design_out.aerofoils = design.aerofoils;
design_out.W = vel.*(1-A)./sin(PHI);
design_out.blades = design.blades;
end
