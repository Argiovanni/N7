% Projet de Telecommunication
% Nom / Prénom : Bongiovanni Arthur
% Nom / Prénom : Houot Léa
% Groupe : 1SN-B

clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4 Comparaison du modulateur DVS-S avec un modulateur 4-ASK        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Implantation de la modulation 4-ASK
% Constantes

%Frequence d'echantillonage
Fe = 6000;
% Debit binaire
Rb = 3000;
% Temps bianire
Tb = 1/Rb;
M = 4;
n = 2;
% Temps symbole
Ts = n*Tb;
% Nombre de bits
Nbits = 300000;
% Temps d'echantillonage
Te = 1/Fe;
% Nombres de symboles
Ns = Fe*Ts;
%Roll off
alpha = 0.35;
% Span
L = 15;
% retard
retard = L*Ns/2;
% amplitude
V = 1;


%% Debut de modulation
% Génération des bits
bits = randi([0 1],1, Nbits);

% Mapping 4-ASK (de Gray)
mapping = [-3, -1, 3, 1];

%génération des symboles complexes dk
dk = mapping(1+bi2de(reshape(bits, Nbits/2, 2), 'left-msb'));

% Suréchantillonage
surech = zeros(1,Ns - 1);
surech(1) = 1;
Xk = kron(dk,[1 zeros(1,Ns-1)]);

% Filtre de mise en forme
h = rcosdesign(alpha,L,Ns);

%Ajout du zero padding sur le Xk
Signal_Filtre = filter(h,1,[Xk zeros(1,retard)]);

% rattrapage du retard
xe = Signal_Filtre(retard+1 : end);
xe_reel = real(xe);
xe_imag = imag(xe);

%% constelation en sortie du mapping
figure(1)
plot(dk, zeros(1, length(dk)), 'rx')
grid on
xlabel('I')
ylabel('Q')
title("Constellation observée en sortie du mapping"); % le point en (0;0) est du au zero padding.


%% DENSITE SPECTRALE de PUISSANCE:

[S_xe] = pwelch(xe, [], [], [], Fe, 'twosided');
% S_xe_log = 10*log(S_xe/max(S_xe));

% Échelle de fréquence
taille_S_xe = length(S_xe);
Echelle_Frequentielle = (-taille_S_xe/2:taille_S_xe/2-1)*Fe/taille_S_xe;

% Tracé de la DSP de l'enveloppe complexe associée au signal à transmettre
figure(2)
semilogy(Echelle_Frequentielle, fftshift(S_xe),'r')
hold on
% ajout du trace de la dsp en db de la partie 3
load('S_xe_partie_3.mat')
% S_xe_log = 10*log(S_xe/max(S_xe));
semilogy(Echelle_Frequentielle, fftshift(S_xe), 'b')

grid on
xlabel('f (Hz)')
ylabel('S_x(db)')
title("Tracé de la DSP de l'enveloppe complexe associée au signal à transmettre");
legend('4-ASK', 'QPSK');


%% Canal avec bruit

EbN0dB = 0:0.5:6;
N = length(EbN0dB);

taille_max_zm = 200;
tab_zm = zeros(N, taille_max_zm);   %tableau des valeurs des
                                    %échantillons pour le
                                    %tracé des constellations

Px = mean(abs(xe).^2);
TEB_EXP_4ASK = zeros(1,N);

for i=1:N
    Sigma2N = (Px*Ns)/(2*log2(M)*10^(EbN0dB(i)/10));
    bruit = sqrt(Sigma2N) * randn(1, length(xe));
    signal_Bruite = xe + bruit;
    
    % Filtre de réception
    hr = h;
    Signal_z = filter(hr,1,[signal_Bruite zeros(1,retard)]);
    Signal_z = Signal_z(retard + 1: end);
    
    % Echantillonage
    z_ech = Signal_z(1 : Ns : end );
    tab_zm(i, :) = z_ech(1:taille_max_zm);

    % Décision
    symboles = zeros(1,length(z_ech));
    symboles(z_ech > 2) = 3;
    symboles(z_ech >= 0 & z_ech <= 2) = 1;
    symboles(z_ech < -2) = -3;
    symboles(z_ech >= -2 & z_ech < 0) = -1;
    
    
    % Demapping
    [~, rank] = ismember(symboles, mapping);
    binary = de2bi(rank-1, 'left-msb');
    bits_decide3 = reshape(binary,1,Nbits);
    % Calcul du iéme TEB
    nb_erreur= length(find(bits_decide3 ~= bits));
    TEB_EXP_4ASK(1,i)= nb_erreur/(Nbits); % TEB= TES/2 avec Nbits=2*length(dk)
    
end
% Calcul du TEB théorique avec qfunc:nb_erreur3
TEB_TH_4ASK = (3/4) *qfunc(sqrt((4/5)*(10.^(EbN0dB/10))));
%Tracé du TEB theorique et du TEB experimental.
figure(3);
semilogy(EbN0dB, TEB_EXP_4ASK,'*b-');
hold on;
semilogy(EbN0dB, TEB_TH_4ASK,'sr-');
hold off;
title("TEB estimé et théorique de la chaine sur fréquence porteuse");
legend({'TEB_{estime}','TEB_{Theorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

% sauvegarde donnée pour comparaison
save('TEB_EXP_part4-ask','TEB_EXP_4ASK');

% comparaison avec part3
figure(4);
semilogy(EbN0dB, TEB_EXP_4ASK,'*b-');
hold on;
load('TEB_EXP_part3');
semilogy(EbN0dB, TEB_EXP_QPSK,'*r-');
grid on;
legend('TEB avec 4-ASK', 'TEB avec QPSK')

%% Constellation en sortie de l'échantilloneur
for i = 1:2:length(EbN0dB)
    figure(((i+1)/2) +4);
    plot([-3, -1, 1, 3], zeros(1, 4), 'ro', 'LineWidth', 2)
    hold on
    plot(tab_zm(i, :), zeros(1, length(tab_zm(i, :))), 'bx')
    grid on
    xlabel('I')
    ylabel('Q')
    title(["Constellation observée en sortie de l'échantillonneur pour E_b/N_0 = ", EbN0dB(i), "dB"]);
    legend('Constellation en sortie de mapping', "Constellation observée en sortie de l'échantillonneur pour E_b/N_0 = "+ EbN0dB(i)+ "dB");
     
end








