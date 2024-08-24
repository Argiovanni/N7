% fonction estim_moments (pour exercice_3.m)

function [moyennes,ecarts_types] = estim_moments(liste_parametres)
    
moyennes = mean(liste_parametres);
ecarts_types = sqrt(mean(liste_parametres.*liste_parametres) - moyennes^2);


end
