% function ACP (pour exercice_2.m)

function [C,bornes_C,coefficients_RVG2gris] = ACP(X)
    
    moyenne = mean(X);
    X_centered = X - repmat(moyenne,size(X,1),1);
    sigma = (1/size(X,1)) * (X_centered' * X_centered);
    [W,D] = eig(sigma);
    
    [Val_P_sigma,index] = sort(diag(D), "descend");
    Vect_P_sigma = [W(:,index(1)), W(:,index(2)), W(:,index(3))];
    C = X * Vect_P_sigma;
    
    bornes_C = [min(C(:)), max(C(:))];

    coefficients_RVG2gris = Vect_P_sigma(:,1)/sum(Vect_P_sigma(:,1));

    
end
