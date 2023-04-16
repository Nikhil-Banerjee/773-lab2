function [rpm, torque, power] = solve_for_turbine_performance(vel, design, max_rpm, conf)
% solves for the turbine (define by design) performance for a given
% inflowing windspeed by equating the BEM analysis (which returns the
% estimated torque for a given design) with the rpm vs torque curve for the
% generator used in this project.
% inputs:   vel - inflow wind speed (m/s)
%           design - turbine design
% outputs:  rpm - revolutions per minute
%           torque - turbine torque (Nm)
%           power - power output of the turbine at wind speed vel (W)

%global conf;
RPM2RADS = conf.RPM2RADS;

% define different starting points for the root search. 
test_rpms = conf.starting_rpms;
options = optimset('fzero');
options.Display = 'off';
check_edge_case = true;
for IC = test_rpms
    
    % find where the turbine performance curves and the generator torque
    % curve intersect
    try
        rpm = fzero(@(x) compute_bem(x, vel, design, false, conf) - torque_from_RPM(x), IC, options);
    catch ME
        if (strcmp(ME.identifier,'MATLAB:fzero:ValueAtInitGuessComplexOrNotFinite'))
            rpm = NaN;
        else
            rethrow(ME);
        end
    end
    if ~isnan(rpm)
        [~, design_root] = compute_bem(rpm, vel, design, false, conf);
        if check_valid_soln(design_root, conf)
            if check_edge_case
                % sometimes roots at the very edge of the valid domain can 
                % pass checks - check whether a slightly higher rpm is
                % valid to ensure this isn't an edge case.
                [~, design_root_1] = compute_bem(rpm + 5, vel, design, false, conf);
                [~, design_root_2] = compute_bem(rpm - 5, vel, design, false, conf);
                if check_valid_soln(design_root_1, conf) && check_valid_soln(design_root_2, conf)
                    break   % found a valid soln (root) - break from loop
                else
                    rpm = NaN;
                end
            else
                break       % found a valid soln (root) - break from loop
            end
        else
            rpm = NaN;      % soln (root) exists - but it is not a valid
        end
    end
end

if isnan(rpm)                       % Return NaN if a valid root cannot be found
    torque = NaN;
    power = NaN;
else                                % calculate operating torque and power
    torque = torque_from_RPM(rpm);
    power = torque*rpm*RPM2RADS;
end
end
