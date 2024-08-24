% fonction calcul_bon_partitionnement (pour l'exercice 1)

function meilleur_pourcentage_partitionnement = ...
                    calcul_bon_partitionnement(Y_pred,Y)

    p = perms(1:3);
    score = zeros(length(p),1);
    for i = 1:length(p)
        Y_copy = Y_pred;
        Y_copy(Y_pred==1) = p(i,1);
        Y_copy(Y_pred==2) = p(i,2);
        Y_copy(Y_pred==3) = p(i,3);
        score(i) = sum(Y_copy == Y);
    end
    [max_val,~] = max(score);
    meilleur_pourcentage_partitionnement = (max_val / length(Y))*100;
end