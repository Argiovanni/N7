% Projet de Telecommunication
% Nom / Prénom : Bongiovanni Arthur
% Nom / Prénom : Houot Léa
% Groupe : 1SN-B

clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5 Comparaison du modulateur DVS-S                                 %%
%% avec un des modulateurs proposés par le DVB-S2                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1 - Implantation de la modulation DVB-S2
% Constantes

%Frequence d'echantillonage
Fe = 6000;
% Debit binaire
Rb = 3000;
% Temps bianire
Tb = 1/Rb;
% Temps symbole
M = 8;
n = 3;
Ts = n*Tb;
% Nombre de bits
Nbits = 300000;
% Temps d'echantillonage
Te = 1/Fe;
% Nombres de symboles
Ns = Fe*Ts;
%Roll off
alpha = 0.20;
% Span
L = 15;
% retard
retard = L*Ns/2;
% amplitude
V = 1;

%% Debut de modulation
% Génération des bits
bits = randi([0 1],1, Nbits);

%génération des symboles complexes dk
dk = pskmod(reshape(bits, n, Nbits/n), M, PlotConstellation=true, InputType='bit');

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


%% tracé de signaux %(utile ?)
Temps = 0:Te:(length(xe)-1)*Te;
figure(2);
subplot(2,1,1);plot(Temps, xe_reel);
xlabel("Temps(s)");
ylabel("Amplitude");
title("signaux générés sur les voies en phase");
grid on;
subplot(2,1,2);plot(Temps, xe_imag);
xlabel("Temps(s)");
ylabel("Amplitude");
title("signaux générés sur les voies en quadrature");
grid on;

%% DENSITE SPECTRALE de PUISSANCE:
[S_xe] = pwelch(xe, [], [], [], Fe, 'twosided');
% Échelle de fréquence
taille_S_xe = length(S_xe);
Echelle_Frequentielle = (-taille_S_xe/2:taille_S_xe/2-1)*Fe/taille_S_xe;

% Tracé de la DSP de l'enveloppe complexe associée au signal à transmettre
figure(3)
semilogy(Echelle_Frequentielle, fftshift(S_xe), 'r')
hold on
% ajout du trace de la dsp en db de la partie 3
load('S_xe_partie_3.mat')
semilogy(Echelle_Frequentielle, fftshift(S_xe), 'b')
grid on
xlabel('f (Hz)')
ylabel('S_xe(f)')
title("Tracé de la DSP de l'enveloppe complexe associée au signal à transmettre");
legend('8-PSK', 'QPSK');

%% Canal avec bruit

EbN0dB = 0:0.5:6;
N = length(EbN0dB);

taille_max_zm = 500;
tab_zm = zeros(N, taille_max_zm);   %tableau des valeurs des
                                    %échantillons pour le
                                    %tracé des constellations

Px = mean(abs(xe).^2);
TEB_EXP_8PSK = zeros(1,N);

for i=1:N
    Sigma2N = (Px*Ns)/(2*log2(M)*10^(EbN0dB(i)/10));
    bruit_I = sqrt(Sigma2N) * randn(1, length(xe));
    bruit_Q = sqrt(Sigma2N) * randn(1, length(xe));
    signal_Bruite = xe + bruit_I + 1i*bruit_Q;
    
    % Filtre de réception
    hr = h;
    Signal_z = filter(hr,1,[signal_Bruite zeros(1,retard)]);
    Signal_z = Signal_z(retard + 1: end);
    
    % Echantillonage
    z_ech = Signal_z(1 : Ns : end );
    tab_zm(i, :) = z_ech(1:taille_max_zm);

    % Démodulation
    bm = pskdemod(z_ech, M, OutputType='bit');
    bm = bm(:)';
    
    % Calcul du iéme TEB
    nbr_erreurs =length(find(bits~=bm));
    TEB_EXP_8PSK(1,i) = nbr_erreurs/length(bm);
    
end
% Calcul du TEB théorique avec qfunc
TEB_TH_8PSK = (2/n) * qfunc(sqrt( 6*(10 .^ (EbN0dB / 10))) * sin(pi/M));
% TEB_TH_8PSK = (2/n)*(1-cdf("Normal", sqrt((2*n*10.^(EbN0dB/10)))*sin(pi/M), 0, 1));
%Tracé du TEB theorique et du TEB experimental.
figure(4);
semilogy(EbN0dB, TEB_EXP_8PSK,'*b-');
hold on;
semilogy(EbN0dB, TEB_TH_8PSK,'sr-');
hold off;
title("TEB estimé et théorique de la chaine sur fréquence porteuse");
legend({'TEB_{estime}','TEB_{Theorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

% sauvegarde donnée pour comparaison
save('TEB_EXP_part5','TEB_EXP_8PSK');


% comparaison avec part3
figure(5);
semilogy(EbN0dB, TEB_EXP_8PSK,'*b-');
hold on;
load('TEB_EXP_part3');
semilogy(EbN0dB, TEB_EXP_QPSK,'*r-');
grid on;
legend('TEB avec 8-PSK', 'TEB avec QPSK')

%% Constellation en sortie de l'échantilloneur
for i = 1:2:length(EbN0dB)
    figure(((i+1)/2) +5);
    plot(dk(:,1:taille_max_zm), 'rx', 'Linewidth', 2)
    % plot(dk, 'rx', 'LineWidth', 2)
    hold on
    plot(tab_zm(i, :), 'bo')
    grid on
    xlabel('I')
    ylabel('Q')
    title(["Constellation observée en sortie de l'échantilloneur pour E_b/N_0 = ", EbN0dB(i), "dB"] );
    legend('Constellation en sortie de mapping', "Constellation observée en sortie de l'échantillonneur pour E_b/N_0 = "+ EbN0dB(i)+ "dB");
     
end

%% 2 - Comparaison des modulateurs DVB-S (part2 et 3) et DVB-S2

% QPSK est plus robuste en termes de TEB et efficacité de puissance, 
% ce qui la rend plus adaptée aux environnements bruyants ou lorsque la puissance de transmission est limitée.
%
% 8-PSK offre une meilleure efficacité spectrale, 
% ce qui est bénéfique pour maximiser la capacité de transmission dans une bande passante limitée, 
% mais cela se fait au prix d'une plus grande sensibilité au bruit.