function [beta, norm_grad_f_beta, f_beta, norm_delta, nb_it, exitflag] ...
          = Algo_Newton(Hess_f_C14, beta0, option)
%************************************************************
% Fichier  ~gergaud/ENS/Optim1a/TP-optim-20-21/Newton_ref.m *
% Novembre 2020                                             *
% Université de Toulouse, INP-ENSEEIHT                      *
%************************************************************
%
% Newton r�sout par l'algorithme de Newton les problemes aux moindres carres
% Min 0.5||r(beta)||^2
% beta \in R^p
%
% Parametres en entrees
% --------------------
% Hess_f_C14 : fonction qui code la hessiennne de f
%              Hess_f_C14 : R^p --> matrice (p,p)
%              (la fonction retourne aussi le residu et la jacobienne)
% beta0  : point de départ
%          real(p)
% option(1) : Tol_abs, tolérance absolue
%             real
% option(2) : Tol_rel, tolérance relative
%             real
% option(3) : nitimax, nombre d'itérations maximum
%             integer
%
% Parametres en sortie
% --------------------
% beta      : beta
%             real(p)
% norm_gradf_beta : ||gradient f(beta)||
%                   real
% f_beta    : f(beta)
%             real
% res       : r(beta)
%             real(n)
% norm_delta : ||delta||
%              real
% nbit       : nombre d'itérations
%              integer
% exitflag   : indicateur de sortie
%              integer entre 1 et 4
% exitflag = 1 : ||gradient f(beta)|| < max(Tol_rel||gradient f(beta0)||,Tol_abs)
% exitflag = 2 : |f(beta^{k+1})-f(beta^k)| < max(Tol_rel|f(beta^k)|,Tol_abs)
% exitflag = 3 : ||delta)|| < max(Tol_rel delta^k),Tol_abs)
% exitflag = 4 : nombre maximum d'itérations atteint
%      
% ---------------------------------------------------------------------------------

 %D�claration variables
    beta = beta0;
    [H_f, res, J_res] = Hess_f_C14(beta);
    norm_grad_f_beta =sqrt(sum((J_res'*res).^2));
    f_beta = (1/2)*sum(res.^2);
    beta_old = beta;
    norm_delta = norm(beta-beta_old);
    nb_it = 0;
    exitflag = 0;

    while  exitflag == 0
        %Calcul
        f_beta_old = f_beta;
        beta_old = beta;
        [H_f, res, J_res] = Hess_f_C14(beta_old);
        delta = (-H_f)\(J_res'*res);
        beta=delta+beta_old;
        [~, res, J_res] = Hess_f_C14(beta);
        norm_delta=norm(delta);
        norm_grad_f_beta = sqrt(sum((J_res'*res).^2));
        f_beta = (1/2)*sum(res.^2);
        nb_it=nb_it+1;
        %V�rification conditions
        if norm_grad_f_beta <= max(option(2)*norm_grad_f_beta,option(1))
            exitflag = 1;
        elseif abs(f_beta-f_beta_old) <= max(option(2)*abs(f_beta_old),option(1))
            exitflag = 2;
        elseif norm_delta <= max (option(2)*norm(beta_old),option(1))
            exitflag = 3;
        elseif nb_it >= option(3)
            exitflag=4;
        end
    end
end
