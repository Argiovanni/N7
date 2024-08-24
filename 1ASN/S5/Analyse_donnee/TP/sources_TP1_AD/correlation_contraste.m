% function correlation_contraste (pour exercice_1.m)

function [correlation,contraste] = correlation_contraste(X)
    %Calculer SIGMA,la matrice de var/cov des VA correspondnant aux 3 cannaux, de dim : 3x3
    moyenne = mean(X);
    X_centered = X - repmat(moyenne,size(X,1),1);
    sigma = (1/size(X,1)) * (X_centered' * X_centered);
    
    cov_RV = sigma(1,2); cov_RB = sigma(1,3); cov_VB = sigma(2,3);
    var_R = sigma(1,1); var_V = sigma(2,2); var_B = sigma(3,3);

    %Calculer le coef de corrélation linéaire
    correlation = [0; 0; 0];
    correlation(1) = cov_RV/sqrt(var_R * var_V);
    correlation(2) = cov_RB/sqrt(var_R * var_B);
    correlation(3) = cov_VB/sqrt(var_V * var_B);

    %Calculer la proportion de contraste de chaque canal
    contraste = [0;0;0];
    contraste(1) = var_R / (var_R + var_V + var_B);
    contraste(2) = var_V / (var_R + var_V + var_B);
    contraste(3) = var_B / (var_R + var_V + var_B);

end
