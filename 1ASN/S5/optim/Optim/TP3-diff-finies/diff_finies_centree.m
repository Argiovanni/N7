% Auteur : J. Gergaud
% décembre 2017
% -----------------------------
% 



function Jac= diff_finies_centree(fun, x, option)
%
% Cette fonction calcule les différences finies centrées sur un schéma
% Paramètres en entrées
% fun : fonction dont on cherche à calculer la matrice jacobienne
%       fonction de IR^n à valeurs dans IR^m
% x   : point où l'on veut calculer la matrice jacobienne
% option : précision du calcul de fun (ndigits)
%
% Paramètre en sortie
% Jac : Matrice jacobienne approximé par les différences finies
%        real(m,n)
% ------------------------------------
    Jac = ones(size(fun(x),1),size(x,1));
    I=eye(size(x,1));
    omega=max(eps,10^(-option));
    for direction = 1:size(x,1)
        h=(omega^(1/3))*max(abs(x(direction)),1)*sign(x(direction));
        Jac(:,direction)=(fun(x+I(:,direction)*h)-fun(x-I(:,direction)*h))./(2*h);
    end
end

function s = sgn(x)
% fonction signe qui renvoie 1 si x = 0
if x==0
  s = 1;
else 
  s = sign(x);
end
end





