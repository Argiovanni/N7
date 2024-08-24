% Fonction calcul_proba (exercice_2.m)

function [x_min,x_max,probabilite] = calcul_proba(E_nouveau_repere,p)

    n=size(E_nouveau_repere,1);
    x_min = min(E_nouveau_repere(:,1));
    x_max = max(E_nouveau_repere(:,1));
    N=floor((x_max-x_min)*(max(E_nouveau_repere(:,2))-min(E_nouveau_repere(:,2))));
    probabilite=1-binocdf((n-1),N,p);
    
end