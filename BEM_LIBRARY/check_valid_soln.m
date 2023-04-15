function bool = check_valid_soln(design)
% checks whether a solution (i.e. a design operating at a particular rpm and
% wind speed is valid). For a solution to be valid, the values of a and a'
% must be greater than zero. 

% YOU CAN ADD TO THIS TO CONSTRAIN YOUR SOLN IF REQUIRED

if all(design.a > 0) && all(design.a_prime > 0)
    bool = true;
else
    bool = false;
end
end
