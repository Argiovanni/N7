%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               TP1 de Traitement Numérique du Signal
%                   SCIENCES DU NUMERIQUE 1A
%                       Fevrier 2024 
%                        Prénom Nom
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=1;                %amplitude 
f1=1000;            %fréquence en Hz s1
T1=1/f1;            %période en secondes s1
f2=3000;            %fréquence en Hz s2
T2=1/f2;            %période en secondes s2
N=100;              %nombre d'échantillons souhaités pour le cosinus
Fe=10000;           %fréquence d'échantillonnage en Hz
Te=1/Fe;            %période d'échantillonnage en secondes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EX1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temps = 0:Te:(N-1)*Te;
x = A*(cos(2*pi*f1*temps) + cos(2*pi*f2*temps));

figure
plot(temps,x);
grid
xlabel("temps(s)")
ylabel("signal x")
title("ex1.2")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EX2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fc = 2000;
tc = 1/fc;
N2 = 101;
plage_temps = -(N2-1)*Te/2 :Te:(N2-1)*Te/2;

x2 = (2*fc / Fe)*sinc(2*plage_temps*fc);
figure
plot(plage_temps,x2);
grid
xlabel("temps(s)")
ylabel("signal h ?")
title("h(t)")
X = fft(x);
X2 = fft(x2); %h(t)
echelle_freq =(-Fe/2):(Fe/N):(Fe/(2*N))*(N-1);
figure
semilogy(echelle_freq,fftshift(abs(X)),'b');
hold on
echelle_freq =(-Fe/2):(Fe/N2):(Fe/(2*N2))*(N2-1);
semilogy(echelle_freq,fftshift(abs(X2)),'r');
grid
xlabel("frequence hz")
ylabel("tfd")
title("ex2.1")


