function fit = turbineFitness(sol, conf)

% Uses global variable to import conf details
%global conf

try 
    % Validates sol, throwing an error if invalid
    validate(sol,conf)
catch
    % If solution is invalid, fitness is set to 0
    fit = 0;
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
    if sum(isnan(Powers)) > 0 || max(RPMs) > conf.rpmub
        fit = 0;
    else % Negative since GA minimizes
        fit = -sum(Powers .* conf.probability');
    end
end