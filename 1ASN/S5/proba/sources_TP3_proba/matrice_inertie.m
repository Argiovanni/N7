% Fonction matrice_inertie (exercice_2.m)

function [M_inertie,C] = matrice_inertie(E,G_norme_E) 
   
    pi = sum(G_norme_E);
    E_x = E(:, 2);
    E_y = E(:, 1);
    
    x_bar = sum(E_x.*G_norme_E)/pi;
    y_bar = sum(E_y.*G_norme_E)/pi;
    C = [x_bar y_bar];

    M_inertie = zeros(2);
    M_inertie(1, 1) = sum(G_norme_E.*((E_x - x_bar).^2))/pi;
    M_inertie(1, 2) = sum(G_norme_E.*((E_x - x_bar).*(E_y - y_bar)))/pi;
    M_inertie(2, 1) = sum(G_norme_E.*((E_x - x_bar).*(E_y - y_bar)))/pi;
    M_inertie(2, 2) = sum(G_norme_E.*((E_y - y_bar).^2))/pi;

    

end