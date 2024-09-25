% Fonction estim_param_F (exercice_1.m)

function [rho_F,theta_F,ecart_moyen] = estim_param_F(rho,theta)

    B = rho;
    A = [cos(theta) sin(theta)];
    X = A\B;
    xf = X(1);
    yf = X(2);
    rho_F = sqrt(xf^2 + yf^2);
    theta_F = atan2(yf,xf);

    n = length(rho);
    ecart_moyen = sum(A*X - B) / n; 


end