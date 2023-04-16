function fit = turbineFitness(sol, conf)

% Uses global variable to import conf details
%global conf

try
    % Validates sol, throwing an error if invalid
    validate(sol,conf)
catch
    % If solution is invalid, fitness is set to 0
    fit = 500;
    return
end
% Initializes design from solution
design = create_design(sol,conf);

%  Solve for blade performance ast each windspeed
RPMs = zeros(length(conf.windspeed),1);
Powers = zeros(length(conf.windspeed),1);
for i = 1:length(conf.windspeed)
    [RPMs(i), ~, Powers(i)] = solve_for_turbine_performance(...
        conf.windspeed(i), design, conf.rpmub, conf);
    % NOTE initial validation is done in solve_for_design_performance
    % function. Invalid solutions are outputted as NaN
end

% Finds velocities where it is likely that a stall point was encountered by
% checking if lower velocity has higher RPM.
% If it is a stall point, powers and rpms are assigned NaN.
stall_solns = Powers(1:end-1) > Powers(2:end);
if any(stall_solns)
    ind = find(stall_solns) + 1;
    Powers(ind) = NaN;
    RPMs(ind) = NaN;
end

if all(isnan(Powers))
    fit = 5000;
    return
    
else
    avg_power = sum(Powers .* conf.probability', 'omitnan');
end

min_rpm_penalty = 2.5*max(0,100 - min(RPMs));
max_rpm_penalty = 7.5*max(0, max(RPMs) - conf.rpmub);
na_power_penalty = 100*sum(isnan(Powers));

fit = -(avg_power - min_rpm_penalty - max_rpm_penalty - na_power_penalty);
