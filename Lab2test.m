clear all
close all



global conf

conf.bemLib = [pwd '\BEM_LIBRARY']; % The functionality from BEM
addpath(conf.bemLib) % Add the BEM functionality to the path

conf.afBank = [conf.bemLib '\aerofoil_bank']; % Specify the aerofoil bank for later

conf.afCache = 'aerofoil_database.mat' % Give the current aerofoil database
conf.clearance = 0.2;
conf.blades = 8; % The number of blades
conf.nelems = 3; % The number of elements in the blade
conf.foils = {
    {'NACA0012' 'naca1408.dat' 'clarky.dat'}, % The possible foils for elem 1
    {'NACA0012' 'clarky.dat'}, % The possible foils for elem 2
    {'NACA0012' 'clarky.dat' 'NACA0015'}, % The possible foils for elem 3
}
conf.angs = [
    30 45
    20 30
    15 20
    ];
conf.rads = [ % Note that radiius are cumulative starting from conf.clearance
    0.1 0.2;
    0.2 0.4;
    0.4 0.6
    ];
conf.chords = [
    0.15 0.25;
    0.19 0.3;
    0.175 0.27
    ];

conf.rho = 1.29; % Density of air
conf.Re = 70000; % Approximate Reynolds number for design

conf.rpmub = 205; % Maximum RPM allowed
conf.starting_rpms = [150, 200, 175, 125, 100, 75]; % RPMs to start with for zero finding

conf.windspeed   = [  4,   5,   6,   7]; % Range of windspeeds in m/s
conf.probability = [0.3, 0.4, 0.2, 0.1]; % Probability of each windspeed

conf.RPM2RADS = pi/30; % RPM to radians conversion factor

conf.afData = initialise_foils;

plot_lift_and_drag(conf.afData)

conf.tiploss = false; % Turn tip losses on/off

conf.verbose = 0;

sol = [3 2 2 36.8 26.7 19.5 0.2 0.37 0.54 0.25 0.28 0.26];
validate(sol)

design = create_design(sol);

[rpm, trq, pow] = solve_for_turbine_performance(conf.windspeed(2), ...
    design, conf.rpmub);
disp(design)
disp(['has RPM = ' num2str(rpm) ', torque = ' num2str(trq) ...
      ' and power = ' num2str(pow)])

plot_design_analysis(conf.windspeed, 0:5:conf.rpmub, design, conf.rpmub, 1)
