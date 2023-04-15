function validate(sol,conf)

%global conf;
%load('conf_variable.mat','conf')

% Check foils
for elem = 1:conf.nelems,
    if conf.verbose, disp(['Checking foil ' num2str(elem)]), end
    if (1 <= sol(elem)) & (sol(elem) <= length(conf.foils{elem})),
        if conf.verbose, disp('pass'), end
    else
        error(['Foil ' num2str(elem) ' has an invalid value = ' ...
               num2str(sol(elem)) newline '(should be between ' num2str(1) ...
               ' and ' num2str(length(conf.foils{elem})) ')'])
    end
end
% Check angles
offset = conf.nelems;
for elem = 1:conf.nelems,
    if conf.verbose, disp(['Checking angle ' num2str(elem)]), end
    if (conf.angs(elem, 1) <= sol(offset + elem)) & ...
       (sol(offset + elem) <= conf.angs(elem, 2)),
        if conf.verbose, disp('pass'), end
    else
        error(['Angle ' num2str(elem) ' has an invalid value = ' ...
               sol(offset + elem) newline '(should be between ' ...
               num2str(conf.angs(elem, 1)) ...
               ' and ' num2str(conf.angs(elem, 2)) ')'])
    end
end
% Check radii
offset = 2 * conf.nelems;
for elem = 1:conf.nelems,
    if conf.verbose, disp(['Checking radius ' num2str(elem)]), end
    if (conf.rads(elem, 1) <= sol(offset + elem)) & ...
       (sol(offset + elem) <= conf.rads(elem, 2)),
        if conf.verbose, disp('pass'), end
    else
        error(['Radius ' num2str(elem) ' has an invalid value = ' ...
               sol(offset + elem) newline '(should be between ' ...
               num2str(conf.rads(elem, 1)) ...
               ' and ' num2str(conf.rads(elem, 2)) ')'])
    end
end
% Check chords
offset = 3 * conf.nelems;
for elem = 1:conf.nelems,
    if conf.verbose, disp(['Checking chord ' num2str(elem)]), end
    if (conf.chords(elem, 1) <= sol(offset + elem)) & ...
       (sol(offset + elem) <= conf.chords(elem, 2)),
        if conf.verbose, disp('pass'), end
    else
        error(['Chord ' num2str(elem) ' has an invalid value = ' ...
               sol(offset + elem) newline '(should be between ' ...
               num2str(conf.chords(elem, 1)) ...
               ' and ' num2str(conf.chords(elem, 2)) ')'])
    end
end

end