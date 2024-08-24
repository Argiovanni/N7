% Projet de Telecommunication
% Nom / Prénom : Bongiovanni Arthur
% Nom / Prénom : Houot Léa
% Groupe : 1SN-B

clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3 chaine passe-bas équivalente                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Répartitions en deux vecteurs
ak_sans_padding = 2*bits(1:2:end)-1;
bk_sans_padding = 2*bits(2:2:end)-1;

% Zero padding
ak = [ak_sans_padding zeros(1, retard)];
bk = [bk_sans_padding zeros(1, retard)];

% Calcul de dk
dk_sans_padding = ak_sans_padding + 1j*bk_sans_padding;
dk = ak + 1j*bk;

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

%% tracé de signaux
Temps = 0:Te:(length(xe)-1)*Te;
figure(1);
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

%% constelation en sortie du mapping
figure(2)
plot(dk_sans_padding, 'rx', 'LineWidth', 2)
grid on
xlabel('I')
ylabel('Q')
title("Constellation observée en sortie du mapping"); % le point (0,0) est du au zero padding


%% DENSITE SPECTRALE de PUISSANCE:

[S_xe] = pwelch(xe, [], [], [], Fe, 'twosided');

% Sauvegarde de la DSP pour la comparaison avec celle pour 4-ASK
save('S_xe_partie_3', 'S_xe');

% Échelle de fréquence
taille_S_xe = length(S_xe);
Echelle_Frequentielle = (-taille_S_xe/2:taille_S_xe/2-1)*Fe/taille_S_xe;

% Tracé de la DSP de l'enveloppe complexe associée au signal à transmettre
figure(3)
semilogy(Echelle_Frequentielle, fftshift(S_xe))
grid on
xlabel('f (Hz)')
ylabel('S_xe(f)')
title("Tracé de la DSP de l'enveloppe complexe associée au signal à transmettre");


%% Canal avec bruit

EbN0dB = 0:0.5:6;
N = length(EbN0dB);

taille_max_zm = 200;
tab_zm = zeros(N, taille_max_zm);   %tableau des valeurs des
                                    %échantillons pour le
                                    %tracé des constellations

Px = mean(abs(xe).^2);
TEB_EXP_QPSK = zeros(1,N);

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

    z_ech_R = real(z_ech);
    z_ech_I = imag(z_ech);
    % Décision
    symboles_decides_real2 = sign(z_ech_R);
    symboles_decides_Im2 = sign(z_ech_I);
    % Demapping
    bits_real2 = (symboles_decides_real2 + 1)/2;
    bits_Im2 = (symboles_decides_Im2 + 1)/2;
    bits_decides2 = zeros(1,Nbits);
    bits_decides2(1:2:end) = bits_real2(1 : length(bits_real2) -retard);
    bits_decides2(2:2:end) = bits_Im2(1 : length(bits_Im2) -retard);
    % Calcul du iéme TEB
    nb_erreur2 = length(find(bits~=bits_decides2));
    TEB_EXP_QPSK(1,i)= nb_erreur2/(Nbits); % TEB= TES/2 avec Nbits=2*length(dk)
    
end
% Calcul du TEB théorique avec qfunc
TEB_TH_QPSK = qfunc(sqrt( 2*(10 .^ (EbN0dB / 10)) ));
%Tracé du TEB theorique et du TEB experimental.
figure(6);
semilogy(EbN0dB, TEB_EXP_QPSK,'*b-');
hold on;
semilogy(EbN0dB, TEB_TH_QPSK,'sr-');
hold off;
title("TEB estimé et théorique de la chaine sur fréquence porteuse");
legend({'TEB_{estime}','TEB_{Theorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

% sauvegarde donnée pour comparaison
save('TEB_EXP_part3','TEB_EXP_QPSK');

% comparaison avec part2
figure(7);
semilogy(EbN0dB, TEB_EXP_QPSK,'*b-');
hold on;
load('TEB_EXP_part2');
semilogy(EbN0dB, TEB_EXP_QPSK,'*r-');
grid on;
legend('TEB avec QPSK', 'TEB avec chaine passe-bas équivalente');

%% Constellation en sortie de l'échantilloneur
for i = 1:2:length(EbN0dB)
    figure(((i+1)/2) +7);
    plot(dk_sans_padding, 'rx', 'LineWidth', 2)
    hold on
    plot(tab_zm(i, :), 'bo')
    grid on
    xlabel('I')
    ylabel('Q')
    title(["Constellation observée en sortie de l'échantilloneur pour E_b/N_0 = ", EbN0dB(i), "dB"] );
    legend('Constellation en sortie de mapping', "Constellation observée en sortie de l'échantillonneur pour E_b/N_0 = "+ EbN0dB(i)+ "dB");
     
end


% intérêt de la chaine passe-bas équivalente : bcp moins d'échantillon à modéliser






