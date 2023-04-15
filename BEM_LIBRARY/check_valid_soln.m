function bool = check_valid_soln(design, conf)
% checks whether a solution (i.e. a design operating at a particular rpm and
% wind speed is valid). For a solution to be valid, the values of a and a'
% must be greater than zero. 

% YOU CAN ADD TO THIS TO CONSTRAIN YOUR SOLN IF REQUIRED
tol = 1e-4;

if all(design.a > tol) && all(design.a_prime > tol) && all(design.alpha > conf.angs(:,1)' + tol) && all(design.alpha < conf.angs(:,2)' - tol)
% if all(design.a > tol) && all(design.a_prime > tol)    
    bool = true;
else
    bool = false;
end
end
