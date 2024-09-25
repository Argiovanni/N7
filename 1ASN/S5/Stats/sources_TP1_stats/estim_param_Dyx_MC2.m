% Fonction estim_param_Dyx_MC2 (exercice_2bis.m)

function [a_Dyx,b_Dyx,coeff_r2] = ...
                   estim_param_Dyx_MC2(x_donnees_bruitees,y_donnees_bruitees)

    [x_G, y_G, x_donnees_bruitees_centrees, y_donnees_bruitees_centrees] = ...
                centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees);

    varX = mean(x_donnees_bruitees_centrees.^2);
    varY = mean(y_donnees_bruitees_centrees.^2);
    covXY = mean(x_donnees_bruitees_centrees .* y_donnees_bruitees_centrees);

    r = covXY / sqrt(varX * varY);
    coeff_r2 = r^2;

    a_Dyx = r * sqrt(varY/varX);
    b_Dyx = y_G - a_Dyx*x_G;
    
end