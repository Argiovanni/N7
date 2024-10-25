%--------------------------------------------------------------------------
% ENSEEIHT - 1SN - Calcul scientifique
% TP2 - Factorisation LU
% descente.m
%---------------------------------------------------------------------------

function x = descente(L,p,b)
%---------------------------------------------------------------------------
% Resoudre L x = Pb avec 
% L triangulaire inferieure avec diagonale de 1, b second membre,
% et p vecteur des indices de permutation des lignes.
%---------------------------------------------------------------------------
       
     %Initialisation 
     % cf algo ll slide 17/38 ctd2
     [n, ~] = size(L);
     x=b;
     
     for j = 1:n
        for i = 1:(j-1)
            x(p(j)) = x(p(j)) - L(j,i)*x(p(i));
        end
        %x(p(j)) = x(p(j))/L(j,j); % L(j,j) = 1 normalement
     end
     
end
