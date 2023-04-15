function afData = initialise_foils(conf)

%global conf;

for elem = 1:conf.nelems,
    if elem == 1,
        allFoils = conf.foils{elem};
    else
        allFoils = union(allFoils, conf.foils{elem});
    end
%    disp(allFoils)
end
disp(['Set of foils = ' allFoils])

if isfile(conf.afCache),
    load(conf.afCache);
    toAdd = [];
    for foil = allFoils,
        if ~isKey(afData, foil),
            toAdd = [toAdd foil];
        end
    end
    afData = preprocess_aerofoil_data(toAdd, 1, conf);
else
    toAdd = allFoils;
    afData = preprocess_aerofoil_data(toAdd, 0, conf);
end
if length(toAdd) > 0,
    disp(['Foils to add = ' toAdd])
else
    disp('No foils to add')
end
disp('afData keys = ')
disp(keys(afData))

end

