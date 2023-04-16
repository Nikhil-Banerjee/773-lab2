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

% If solution is invalid, sets fitness to 0

% nan_locations = find(isnan(Powers));
% n_nas = length(nan_locations);
% 
% if n_nas > 0
%     % nas = isnan(Powers);
%     % avg_power = sum(Powers(~nas) .* conf.probability(~nas)');
%     % min_rpm_penalty = 5*max(0,100 - min(RPMs(~nas)));
%     % max_rpm_penalty = 50*max(0, max(RPMs(~nas)) - conf.rpmub);
%     % na_power_penalty = 100*sum(nas);
%     %
%     % fit = -(avg_power - min_rpm_penalty - max_rpm_penalty - na_power_penalty);
% 
%     % Powers = Powers(~nan_locations);
%     % RPMs = RPMs(~nan_locations);
%     % p = conf.probability(~nan_locations);
%     %
%     % avg_power = sum(Powers .* p');
%     % min_rpm_penalty = 5*max(0,100 - min(RPMs));
%     % max_rpm_penalty = 50*max(0, max(RPMs) - conf.rpmub);
%     %
%     % fit = -(avg_power - min_rpm_penalty - max_rpm_penalty - 100*n_nas);
%     fit = n_nas * 100;
% 
% 
% else % Negative since GA minimizes
%     % avg_power = sum(Powers .* conf.probability');
%     %
%     % diff = max(RPMs) - conf.rpmub;
%     % if diff > 1e-4
%     %     fit = -(avg_power - 5*max(0,100 - min(RPMs)) - 50*diff);
%     % else
%     %     fit = -(avg_power - 5*max(0,100 - min(RPMs)));
%     % end
% 
%     avg_power = sum(Powers .* conf.probability');
%     min_rpm_penalty = 5*max(0,100 - min(RPMs));
%     max_rpm_penalty = 50*max(0, max(RPMs) - conf.rpmub);
%     % na_power_penalty = 100*sum(nas);
% 
%     fit = -(avg_power - min_rpm_penalty - max_rpm_penalty);
% 

% end

% na_indices = isnan(Powers);
% avg_power = conf.probability(~na_indices) * Powers(~na_indices);
% min_rpm_penalty = 5*max(0,100 - min(RPMs(~na_indices)));
% max_rpm_penalty = 50*max(0, max(RPMs(~na_indices)) - conf.rpmub);
% na_power_penalty = 100*sum(na_indices);
% 
% fit = -(avg_power - min_rpm_penalty - max_rpm_penalty - na_power_penalty);

stall_solns = Powers(1:end-1) > Powers(2:end);
if any(stall_solns)
    ind = [find(stall_solns), find(stall_solns) + 1];
    ind = unique(ind);
    Powers(ind) = NaN;
    RPMs(ind) = NaN;
end

if all(isnan(Powers))
    fit = 5000;
    return
    
else
    avg_power = sum(Powers .* conf.probability', 'omitnan');
end

min_rpm_penalty = 5*max(0,100 - min(RPMs));
% spread_penalty = 0.5*(max(RPMs) - min(RPMs));
max_rpm_penalty = 5*max(0, max(RPMs) - conf.rpmub);
na_power_penalty = 100*sum(isnan(Powers));

fit = -(avg_power - min_rpm_penalty - max_rpm_penalty - na_power_penalty);


% n_nas = sum(nas);
% Powers = Powers(~nas)
% RPMs = RPMs(~nas)
end