% Fonction estim_param_Dorth_MV (exercice_3.m)

function [theta_Dorth,rho_Dorth] = ...
         estim_param_Dorth_MV(x_donnees_bruitees,y_donnees_bruitees,tirages_theta)

    [x_G, y_G, x_donnees_bruitees_centrees, y_donnees_bruitees_centrees] = ...
                centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees);
  
    X_theta = x_donnees_bruitees_centrees * cos(tirages_theta);
    Y_theta = y_donnees_bruitees_centrees * sin(tirages_theta);

    residus = X_theta + Y_theta;
    r2 = residus .^2;
    scr = sum(r2,1);

    [~,i] = min(scr);
    theta_Dorth = tirages_theta(i);
    rho_Dorth = x_G*cos(theta_Dorth) + y_G*cos(theta_Dorth);


end