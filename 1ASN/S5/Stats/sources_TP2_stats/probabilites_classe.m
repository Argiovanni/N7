% Fonction probabilites_classe (exercice_3.m)

function [probas_classe_1,probas_classe_2] = ...
            probabilites_classe(x_donnees_bruitees,y_donnees_bruitees,sigma,...
                                a_1,b_1,proportion_1,a_2,b_2,proportion_2)

    
    res1 = y_donnees_bruitees - x_donnees_bruitees*a_1 - b_1;
    res2 = y_donnees_bruitees - x_donnees_bruitees*a_2 - b_2;

   probas_classe_1 = proportion_1 * exp(-(res1.^2)/(2*sigma^2));
   probas_classe_2 = proportion_2 * exp(-(res2.^2)/(2*sigma^2));

end