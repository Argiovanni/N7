% Fonction ensemble_E_recursif (exercie_1.m)

function [E,contour,G_somme] = ensemble_E_recursif(E,contour,G_somme,i,j,...
                                                   voisins,G_x,G_y,card_max,cos_alpha)
    
    contour(i,j) = 0;
    nb_voisins = size(voisins,1);
    k = 1;
    while (k <= nb_voisins) && (size(E, 1)<=card_max)
        %recup Kieme voisin
        i_v = i + voisins(k, 1);
        j_v = j + voisins(k, 2);

        %Voisin est contoure ?
        if contour(i_v, j_v) == 1
            %gradient du voisin
            Grad_k = [G_x(i_v, j_v),G_y(i_v, j_v)];
            Grad_k_norme = norm(Grad_k);
            G_somme_norme = norm(G_somme);
            
            %Voisin est aligne?
            if dot((Grad_k/Grad_k_norme),(G_somme/G_somme_norme))>= cos_alpha
                E = [E; i_v, j_v];
                G_somme = G_somme + Grad_k;
                [E, contour, G_somme] = ensemble_E_recursif(E,contour,G_somme,i_v, j_v,...
                                                voisins,G_x,G_y,card_max,cos_alpha);
            end
        end
        k = k+1;
    end

end