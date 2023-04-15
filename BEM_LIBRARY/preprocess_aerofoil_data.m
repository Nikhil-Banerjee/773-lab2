function afData = preprocess_aerofoil_data(foils, loadFile, conf)
%   Inputs:     foils - list of aerofoil name strings to pre-process
%   Outputs:    af_data - dictionary of aerofoil data (indexed by the aerofoil name)
%               that is also saved to conf.afCache 

%global conf;

Re = conf.Re;

afs = unique(foils);           % dont do any double-ups
N_FOILS = length(afs);
if (loadFile)
    load(conf.afCache) % Get the current af_data from the cache file
else
  afData = dictionary(); % Create an empty af_data structure
end
step = 0.25;
alpha_neg = 0:-step:-20; % You may need to change this range and step size
alpha_pos = step:step:20;

% loop through the foils and store the data
for i = 1:N_FOILS
    [pol_neg,~] = callXfoil(afs{i}, alpha_neg, Re, 0);
    pol.alpha = flip(pol_neg.alpha);
    pol.CL = flip(pol_neg.CL);
    pol.CD = flip(pol_neg.CD);
    [pol_pos,~] = callXfoil(afs{i}, alpha_pos, Re, 0);
    pol.name = afs{i};
    pol.Re = pol_pos.Re;
    pol.alpha = [pol.alpha; pol_pos.alpha];
    pol.CD = [pol.CD; pol_pos.CD];
    pol.CL = [pol.CL; pol_pos.CL];
    
    % find any nan values and delete them (we interpolate later anyway)
    not_nan = ~isnan(pol.CL);
    pol.alpha = pol.alpha(not_nan);
    pol.CD = pol.CD(not_nan);
    pol.CL = pol.CL(not_nan);
    pol.CL_original = pol.CL;
     % Calculate moving average of the gradients for CL
    CL_grad = movmean(gradient(pol.CL,pol.alpha), 3);      
    
    % Find the largests negative gradient for positive angles of attack
    zero_index = ceil(length(pol.alpha)/2);
    [min_grad, min_grad_i] = min(CL_grad(zero_index:end));
    min_grad_i = min_grad_i + zero_index;

    % extroplate the CL data (continue the stall angle)
    for ii = min_grad_i:length(pol.CL)
        d_alpha = pol.alpha(ii)-pol.alpha(min_grad_i);
        pol.CL(ii) = pol.CL(min_grad_i) + min_grad*d_alpha;
        if pol.CL(ii) < 0; pol.CL(ii) = 0; end 
    end
    
    pol.CL(end) = 0;  % Make sure the last value of CL is 0

    % create functional form of Cl and Cd (with small amount of smoothing)
    disp(['Fitting ' afs{i} '...'])
    CL_function = fit(pol.alpha,pol.CL,"smoothingspline",'SmoothingParam',0.9);
    CD_function = fit(pol.alpha,pol.CD,"smoothingspline",'SmoothingParam',0.9);
    
    % sample and store from smoothed data - evaluting the function is slow.
    pol.CL_smoothed = CL_function(pol.alpha);
    pol.CD_smoothed = CD_function(pol.alpha);
    
    % store in dictionary
    afData(pol.name) = pol;
    
    % Save dictionary for later use.
    save(conf.afCache, "afData")
end
end