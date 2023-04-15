function design = create_design(sol,conf)

%global conf;

design.blades = conf.blades;

% Create foils
for elem = 1:conf.nelems,
    design.aerofoils(elem) = conf.foils{elem}(sol(elem));
end
% Create angles
offset = conf.nelems;
for elem = 1:conf.nelems,
    design.beta(elem) = sol(offset + elem);
end
% Create radii
offset = 2 * conf.nelems;
for elem = 1:conf.nelems,
    design.r(elem) = sol(offset + elem);
end
% Create chords
offset = 3 * conf.nelems;
for elem = 1:conf.nelems,
    design.chord(elem) = sol(offset + elem);
end

end
