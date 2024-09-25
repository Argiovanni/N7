% Fonction estim_param_Dyx_MV (exercice_1.m)

function [a_Dyx,b_Dyx,residus_Dyx] = ...
           estim_param_Dyx_MV(x_donnees_bruitees,y_donnees_bruitees,tirages_psi)
    
    [x_G, y_G, x_donnees_bruitees_centrees, y_donnees_bruitees_centrees] = ...
                centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees);

    n = length(tirages_psi);    
    

    X_Psi =x_donnees_bruitees_centrees * tan(tirages_psi);
    Y = repmat(y_donnees_bruitees_centrees, 1, n);

    residus = Y - X_Psi;
    r2 = residus .* residus;

    scr = sum(r2,1);

    [~,i] = min(scr); % i est l'indice du min de scr
    psi_min = tirages_psi(i);

    a_Dyx = tan(psi_min);

    b_Dyx = y_G - a_Dyx*x_G;

    residus_Dyx = residus(:,i);
    
end