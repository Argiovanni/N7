% Fonction RANSAC_2droites (exercice_2.m)

function [rho_F_estime,theta_F_estime] = RANSAC_2droites(rho,theta,parametres)

    % Parametres de l'algorithme RANSAC :
    S_ecart = parametres(1); % seuil pour l'ecart
    S_prop = parametres(2); % seuil pour la proportion
    k_max = parametres(3); % nombre d'iterations
    n_donnees = length(rho);
    ecart_moyen_min = Inf;

    for i = 1:k_max
        rnd = randperm(n_donnees,2);
        rho_test_2d = [rho(rnd(1)); rho(rnd(2))];
        theta_test_2d = [theta(rnd(1)); theta(rnd(2))];
        [rho_f, theta_f, ~] = estim_param_F(rho_test_2d, theta_test_2d);
        res = rho - rho_f*cos(theta - theta_f);
        indices = abs(res)<S_ecart;
        if (sum(indices) / n_donnees) > S_prop
            [rho_proche, theta_proche,ecart_moyen] = estim_param_F(rho(indices),theta(indices));
            if ecart_moyen < ecart_moyen_min
                ecart_moyen_min = ecart_moyen;
                rho_F_estime = rho_proche;
                theta_F_estime = theta_proche;
            end
        end
    end

end