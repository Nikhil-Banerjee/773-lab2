function Q = torque_from_RPM(rpm)
% Torque curve vs. RPM for the generator used in testing (see course guide)

for i=1:length(rpm)
    if rpm(i) >= 100
        m = (3.5125-2.736)/(160-100);
    else
        m = (2.736-2.533)/(100-92);
    end
    c = 2.736 - m*100;

    Q(i) = m*rpm(i) + c;
end
end
