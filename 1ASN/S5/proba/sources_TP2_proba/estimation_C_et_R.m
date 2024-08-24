% Fonction estimation_C_et_R (exercice_3.m)

function [C_estime, R_estime] = ...
         estimation_C_et_R(x_donnees_bruitees,y_donnees_bruitees,tirages_C,tirages_R)

    n_donne = size(x_donnees_bruitees,1);
    n_tirage = size(tirages_C,2);
    ecart_x = repmat(x_donnees_bruitees,1,n_tirage) - repmat(tirages_C(1,:),n_donne,1);
    ecart_y = repmat(y_donnees_bruitees,1,n_tirage) - repmat(tirages_C(2,:),n_donne,1);
    residus = sqrt(ecart_x.^2 + ecart_y.^2) - repmat(tirages_R,n_donne,1);
    scr = sum(residus.^2);
    [~,indice_mini] = min(scr);
    C_estime = tirages_C(:,indice_mini);
    R_estime = tirages_R(:,indice_mini);

end