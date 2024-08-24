% fonction moyenne_normalisee_3v (pour l'exercice 1bis)

function x = moyenne_normalisee_3v(I)

    % Conversion en flottants :
    I = single(I);
    
    % Calcul des couleurs normalisees :
    somme_canaux = max(1,sum(I,3));
    r = I(:,:,1)./somme_canaux;
    v = I(:,:,2)./somme_canaux;
    
    % Calcul des couleurs moyennes :
    r_barre = mean(r(:));
    v_barre = mean(v(:));

    % calcul couleur moyenne pourtour rouge
    d=round(0.3*size(I,1));
    s_dg = size(I(:,1:d,:),1) * size(I(:,1:d,:),2);
    s_hb = size(I(1:d,d+1:end-d,:),1) * size(I(1:d,d+1:end-d,:),2) ;
  
    Gauche = reshape(I(:,1:d,:),s_dg,3);
    Haut = reshape(I(1:d,d+1:end-d,:),s_hb,3);
    Bas = reshape(I(end-d+1:end,d+1:end-d,:),s_hb,3);
    Droite = reshape(I(:,end-d+1:end,:),s_dg,3);
    
    pourtour = [Gauche; Haut; Bas; Droite];

    rp = mean(pourtour(:,1));
   
    % calcul couleur moyenne centre rouge
    h = round(0.3*size(I,1));
    centre_hb = int32(size(I,1)/2);
    centre_dg = int32(size(I,2)/2);
    
    centre = I(centre_hb-h:centre_hb+h,centre_dg-h:centre_dg+h,:);
    s_centre = size(centre,1) * size(centre,2);
    C = reshape(centre,s_centre,3);

    rc = mean(C(:,1));

    third_param = rp - rc;

    x = [r_barre v_barre third_param];

end
