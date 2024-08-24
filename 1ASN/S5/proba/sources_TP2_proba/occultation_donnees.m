% Fonction occultation_donnees (donnees_occultees.m)

function [x_donnees_bruitees_visibles, y_donnees_bruitees_visibles] = ...
         occultation_donnees(x_donnees_bruitees, y_donnees_bruitees, ...
                             theta_donnees_bruitees, thetas)
    
    % Recuperation des indices visibles suivant les angles :
    if(thetas(1)<thetas(2))
        indices_donnees_visibles = theta_donnees_bruitees >= thetas(1) & ...
                                   theta_donnees_bruitees <= thetas(2);
    else
        indices_donnees_visibles = theta_donnees_bruitees >= thetas(1) | ...
                                   theta_donnees_bruitees <= thetas(2);
    end

    % Si aucune donnee conservee, on garce la premiere de la liste : 
    
    if ~sum(indices_donnees_visibles)
        indices_donnees_visibles = 1;
    end

    % Conservation des donnees bruitees non occultees :
        
    x_donnees_bruitees_visibles = x_donnees_bruitees(indices_donnees_visibles);
    y_donnees_bruitees_visibles = y_donnees_bruitees(indices_donnees_visibles);


end