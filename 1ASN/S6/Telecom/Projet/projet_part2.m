% Projet de Telecommunication
% Nom / Prénom : Bongiovanni Arthur
% Nom / Prénom : Houot Léa
% Groupe : 1SN-B

clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2 Implantation d'une transmission avec transposition de fréquence %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constantes

%Frequence d'echantillonage
Fe = 24000;
%fréquence porteuse
fp=2000;
% Debit binaire
Rb = 3000;
% Temps bianire
Tb = 1/Rb;
% Temps symbole
M = 4;
n = 2;
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
ak = 2*bits(1:2:end)-1;
bk = 2*bits(2:2:end)-1;

% Zero padding
ak = [ak zeros(1, retard)];
bk = [bk zeros(1, retard)];

% Calcul de dk
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
subplot(2,1,1);plot(Temps,xe_reel);
xlabel("Temps(s)");
ylabel("Amplitude");
title("signaux générés sur les voies en phase");
grid on;
subplot(2,1,2);plot(Temps,xe_imag);
xlabel("Temps(s)");
ylabel("Amplitude");
title("signaux générés sur les voies en quadrature");
grid on;


%% Calcul de x(t) : signal qui va entrer au canal
x = real(xe .* exp(1i*2*pi*fp*Temps));

figure(2);
plot(Temps,x);
xlabel("Temps(s)");
ylabel("Amplitude");
title("signal transmis sur fréquence porteuse");
grid on;

%% DENSITE SPECTRALE:
[S_x] = pwelch(x, [], [], [], Fe, 'twosided');

% Sauvegarde de la DSP pour la comparaison avec
save('S_x_partie_2', 'S_x');

% Échelle de fréquence
taille_S_x = length(S_x);
Echelle_Frequentielle = (-taille_S_x/2:taille_S_x/2-1)*Fe/taille_S_x;

% densite spectrale du signal transmis sur frequence porteuse.
figure(3);
semilogy(Echelle_Frequentielle,fftshift(S_x));
xlabel("Fréquence(Hz)");
ylabel("Puissance");
title("densité spectrale de puissance du signal transmis sur fréquence porteuse");
grid on;

%% Démodulation sans bruit
ordre = 51;
filtre_passe_bas = 2*fp*sinc(((-ordre-1)/2 : (ordre -1)/2) * 2*fp*Te);
retard_canal = (ordre - 1)/2;

figure(11);
plot(filtre_passe_bas);

xcos = x.*cos(2*pi*fp*Temps);
xsin = x.*sin(2*pi*fp*Temps);
xIt = filter(filtre_passe_bas,1,[xcos zeros(1,retard_canal)]);
xIt = xIt(retard_canal+1:end);
xQt = filter(filtre_passe_bas,1,[xsin zeros(1,retard_canal)]);
xQt = xQt(retard_canal+1:end);

% Signal à démoduler en bande de base
% Signal_complex = xcos - 1i*xsin;
Signal_complex = xIt - 1i*xQt;

% Filtre de réception
hr = h;
Signal_z = filter(hr,1,[Signal_complex zeros(1,retard)]);
Signal_z = Signal_z(retard+1:end);
% Echantillonage
z_ech = Signal_z(1 : Ns : end );
z_ech_R = real(z_ech);
z_ech_I = imag(z_ech);

% Décision
symboles_decides_real1 = sign(z_ech_R);
symboles_decides_Im1 = sign(z_ech_I);
% Demapping
bits_real1 = (symboles_decides_real1 + 1)/2;
bits_Im1 = (symboles_decides_Im1 + 1)/2;
bits_decides1 = zeros(1,Nbits);
bits_decides1(1:2:end) = bits_real1(1 : length(bits_real1) -retard);
bits_decides1(2:2:end) = bits_Im1(1 : length(bits_Im1) -retard);

%Calcul du Teb
nb_erreur1 = length(find(bits~=bits_decides1));
TEB_1 = nb_erreur1/(Nbits);
fprintf("TEB de la chaine sur fréquence porteuse sans bruit est : %f\n",TEB_1);
% figure(4);
% nexttile;
% plot(bits);
% nexttile;
% plot(bits_decides1);


%% Canal avec bruit
EbN0dB = 0:0.5:6;
N = length(EbN0dB);
Px = mean(abs(x).^2);
TEB_EXP_QPSK = zeros(1,N);

for i=1:N
    Sigma2N = (Px*Ns)/(2*log2(M)*10^(EbN0dB(i)/10));
    bruit = sqrt(Sigma2N) * randn(1, length(x));
    signal_Bruite = x + bruit;
    % Démodulation sans bruit
    ordre = 51;
    filtre_passe_bas = 2*fp*sinc(((-ordre-1)/2 : (ordre -1)/2) * 2*fp*Te);
    retard_canal = (ordre - 1)/2;
    xcos = 2*signal_Bruite.*cos(2*pi*fp*Temps);
    xsin = 2*signal_Bruite.*sin(2*pi*fp*Temps);
    xIt = filter(filtre_passe_bas,1,[xcos zeros(1,retard_canal)]);
    xIt = xIt(retard_canal+1:end);
    xQt = filter(filtre_passe_bas,1,[xsin zeros(1,retard_canal)]);
    xQt = xQt(retard_canal+1:end);
    
    % Signal à démoduler en bande de base
    Signal_complex = xIt - 1i*xQt;
    
    % Filtre de réception
    hr = h;
    Signal_z = filter(hr,1,[Signal_complex zeros(1,retard)]);
    Signal_z = Signal_z(retard + 1: end);
    
    % Echantillonage
    z_ech = Signal_z(1 : Ns : end );
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
% Calcul du TEB théorique avec qfunc:nb_erreur3
TEB_TH_QPSK = qfunc(sqrt( 2*(10 .^ (EbN0dB / 10))));
%Tracé du TEB theorique et du TEB experimental.
figure(5);
semilogy(EbN0dB, TEB_EXP_QPSK,'*b-');
hold on;
semilogy(EbN0dB, TEB_TH_QPSK,'sr-');
hold off;
title("TEB estimé et théorique de la chaine sur fréquence porteuse");
legend({'TEB_{estime}','TEB_{Theorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

% sauvegarde donnée pour comparaison
save('TEB_EXP_part2','TEB_EXP_QPSK');





