function plot_design_analysis(Vu_range, RPM_range, design, max_rpm, print_warnings, conf)
% plots a given turbine design over a range of operating conditions for
% analysis

%global conf;
RPM2RADS = conf.RPM2RADS;
verbose  = conf.verbose;

dont_plot_garbage = true;

f1 = figure;
f2 = figure;
colour = {[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];
    [0.4940 0.1840 0.5560];[0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]
    [0.6350 0.0780 0.1840]};
i = 1;
for vel = Vu_range

    j = 1;
    bad_count = 0;
    good_count = 0;
    rpm_store = NaN;
    for rpm = RPM_range
        % Break from loop if we are above the upper "reasonable" rpm
        if bad_count > 5
            fprintf("Outside of reasonable RPM range for this wind speed. Continue to next windspeed.\n")
            break
        end
        
        omega = rpm * pi / 30;
        lambda = omega*design.r(end)/vel;
        if lambda < 0 || lambda >15; continue; end

        [Q_out, design_out] = compute_bem(rpm, vel, design, print_warnings, conf);

        % dont plot results if the solution doesnt make physical sense
        if dont_plot_garbage && ~check_valid_soln(design_out,conf)
            if verbose; fprintf("Skipped RPM = %.2f due to non-physical a or a'\n",rpm); end
            if rpm > 100 && good_count >= 10; bad_count = bad_count + 1; end
            continue
        end
        good_count = good_count + 1;
        rpm_store(j) = rpm;
        Q(j) = Q_out;
        j = j + 1;
    end

    if ~isnan(rpm_store),
        figure(f1)
        hold on
        plot(rpm_store,Q.*rpm_store*RPM2RADS,'DisplayName',strcat("V_u = ",num2str(vel)," m/s"), 'Color', colour{i})
        hold off
        figure(f2)
        hold on
        plot(rpm_store,Q,'DisplayName',strcat("V_u = ",num2str(vel)," m/s"), 'Color', colour{i})
        hold off
    end;
    i = i + 1;
    clearvars lambda Q rpm_store
end

figure(f1)
hold on
plot(RPM_range,torque_from_RPM(RPM_range).*RPM_range*RPM2RADS, 'DisplayName', "Generator", "Color",'k', "LineWidth",1)
hold off
legend(Location="southeast")
xlabel("RPM")
ylabel('Power (W)')

figure(f2)
hold on
plot(RPM_range,torque_from_RPM(RPM_range), 'DisplayName', "Generator", "Color",'k', "LineWidth",1)
hold off
legend(Location="northwest")
xlabel("RPM")
ylabel('Torque (Nm)')


figure(f1)
hold on


i = 1;

% Plot the roots, i.e., the operating conditions
for vel = Vu_range
    [intr, torque, power] = solve_for_turbine_performance(vel, design, max_rpm,conf);

    if intr < 0 || intr > max_rpm + 5; continue; end % Dont plot root if outside of design range

    plot(intr, power, '.', "Color", colour{i}, "MarkerSize", 15, 'HandleVisibility', 'off')

    i = i + 1 ;
end

hold off
set(gca, 'YScale', 'log')

end
