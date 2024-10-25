clear all;
format long;

%%%%%%%%%%%%
% PARAMÈTRES
%%%%%%%%%%%%

% taille de la matrice symétrique
n = 200;

% type de la matrice (voir matgen_csad)
% imat == 1 valeurs propres D(i) = i
% imat == 2 valeurs propres D(i) = random(1/cond, 1) avec leur logarithmes
%                                  uniformément répartie, cond = 1e10
% imat == 3 valeurs propres D(i) = cond**(-(i-1)/(n-1)) avec cond = 1e5
% imat == 4 valeurs propres D(i) = 1 - ((i-1)/(n-1))*(1 - 1/cond) avec cond = 1e2
imat = 1;

% on génère la matrice (1) ou on lit dans un fichier (0)
% si vous avez déjà généré la matrice d'une certaine taille et d'un type donné
% vous pouvez mettre cette valeur à 0
genere = 1;

% nombre maximum de couples propres calculés
m = 50;
percentage = 0.4;

% tolérance
eps = 1e-8;

% nombre d'itérations max pour atteindre la convergence
maxit = 10000;

% méthode de calcul
v = 11; % eig

[W, V, flag, q, qv] = eigen_2023(imat, n, v, m, eps, maxit, percentage, [], genere);

fprintf('Qualité des couples propres (par rapport au critère d''arrêt) = [%0.3e , %0.3e]\n', min(qv), max(qv));
fprintf('Qualité des valeurs propres (par rapport au spectre de la matrice) = [%0.3e , %0.3e] \n', min(q), max(q));

% méthode de calcul
v = 12; % basic power method

% on génère la matrice (1) ou on lit dans un fichier (0)
genere = 0;

[W, V, flag, q, qv] = eigen_2023(imat, n, v, m, eps, maxit, percentage, [], genere);

fprintf('Qualité des couples propres (par rapport au critère d''arrêt) = [%0.3e , %0.3e]\n', min(qv), max(qv));
fprintf('Qualité des valeurs propres (par rapport au spectre de la matrice) = [%0.3e , %0.3e] \n', min(q), max(q));