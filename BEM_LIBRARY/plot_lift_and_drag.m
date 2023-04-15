function plot_lift_and_drag(af_data)
% plot the lift and drag coefficient
% inputs:   af_data - dictionary of lift and drag coefficients

key = keys(af_data);
for i = 1:length(key)
    figure
    pol = af_data(key(i));
    hold on
    plot(pol.alpha,pol.CL_original,DisplayName="C_l",LineStyle="none",Marker='.',MarkerSize=6)
    plot(pol.alpha,pol.CL./pol.CD/100,DisplayName="C_l/C_d/100",LineStyle="none",Marker='.',MarkerSize=6)
    plot(pol.alpha,pol.CL_smoothed, DisplayName="C_l (smoothed)")
    plot(pol.alpha,pol.CL_smoothed./pol.CD_smoothed/100,DisplayName="C_l/C_d/100 (smoothed)")

    hold off
    legend(Location="southeast")
    title(pol.name)
    xlabel("Angle of attack (deg.)")
    ylabel('Coefficient (-)')
end
end