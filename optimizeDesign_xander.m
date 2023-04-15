clear all
close all

%global conf

conf.bemLib = [pwd '\BEM_LIBRARY']; % The functionality from BEM
addpath(conf.bemLib) % Add the BEM functionality to the path

conf.afBank = [conf.bemLib '\aerofoil_bank']; % Specify the aerofoil bank for later

conf.afCache = 'aerofoil_database.mat' % Give the current aerofoil database
conf.clearance = 0.2;
conf.blades = 5; % The number of blades
conf.nelems = 3; % The number of elements in the blade %a18sm.data removed
tempfoils = {'e63.dat' 'e71.dat' 'ah7476.dat' 'e62.dat' 's1091.dat' 'goe417a.dat' 'goe494.dat' 'bw3.dat' 'arad6.dat' 'goe427.dat' 'e471.dat' 'goe342.dat' 'goe396.dat' 'sokolov.dat' 'gm15sm.dat' 'e58.dat' 'goe370.dat' 'goe495.dat' 'a18.dat' 'oaf095.dat' 'goe483.dat' 'ah6407.dat' 'fx63100.dat' 'goe484.dat' 'goe458.dat' 'goe456.dat' 'ma409sm.dat' 'goe395.dat' 'goe803h.dat'};
conf.foils = {
    %{'clarky.dat' 'NACA6642' 'NACA0018' 'NACA2415'}, % The possible foils for elem 1
    tempfoils, % The possible foils for elem 2
    tempfoils, % The possible foils for elem 3
    tempfoils
};
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

conf.windspeed   = [   4,    5,    6,    7]; % Range of windspeeds in m/s
conf.probability = [0.25, 0.25, 0.25, 0.25]; % Probability of each windspeed

conf.RPM2RADS = pi/30; % RPM to radians conversion factor

conf.afData = initialise_foils(conf);

conf.tiploss = false; % Turn tip losses on/off

conf.verbose = 0;

% Solution structure is...
% Let x equal the number of elements (conf.nelems)
% x elements of Foil number selected in conf.foils
% x elements of angles of attack
% x elements of radii
% x elements of chord length
% example sol = [1 1 1 36.8 26.7 19.5 0.2 0.37 0.54 0.25 0.28 0.26];

% Initialize lower bounds
nVars = conf.nelems*4;
lb = ones(nVars,1); % Min section number (always 1)
lb(conf.nelems+1:conf.nelems*2) = conf.angs(:,1)'; % Min angle of attack
lb(conf.nelems*2 + 1:conf.nelems*3) = conf.rads(:,1)'; % Min radii
lb(conf.nelems*3 + 1:nVars) = conf.chords(:,1)'; % Min chord length

% Initialize Upper bounds
ub = zeros(conf.nelems,1);
for i = 1:conf.nelems
    ub(i) = length(conf.foils{i}); % Max section number
end
ub(conf.nelems+1:conf.nelems*2) = conf.angs(:,2)'; % Max angle of attack
ub(conf.nelems*2 + 1:conf.nelems*3) = conf.rads(:,2)'; % Max radii
ub(conf.nelems*3 + 1:nVars) = conf.chords(:,2)'; % Max chord length

options = optimoptions('ga', 'PlotFcn', {@gaplotbestf, @gaplotscorediversity},'UseParallel',true, 'MaxStallGenerations',20,'FunctionTolerance',1e-4);

x = ga(@turbineFitness, nVars, [], [], [], [], lb, ub, [], 1:conf.nelems, options)

% Best I found so far for default inputs was -41.1387
% clarky clarky clarky 
% 44.9105 24.8754 15.611
% 0.1122 0.3615 0.5993 
% 0.1759 0.2248 0.2102