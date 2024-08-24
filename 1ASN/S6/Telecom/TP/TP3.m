clear all ; close all;

% Constantes
n_bits = 1000; % Nombre de bits
bits = randi([0 1], n_bits, 1); % Bits à transmettre

Fe = 24000; % Fréquence d'échantillonnage
Te = 1/Fe; % Période d'échantillonnage
Rb = 3000; % Débits de la transmission
Tb = 1/Rb; % Période par bits


%% Etude de l'impact du bruit et du filtrage adapté, notion d'efficacité en puissance
% BRUIT
EbN0 = 0:8;

% Chaine 1 ---------------------------------------------------------
figure('name', 'Chaine 1')

Ts = Tb;            % Période symbole
Ns = Fe * Ts;       % Nombre d'échantillons par bits
h = ones(1, Ns);    % Reponse impulsionnelle du filtre de mise en forme
hr1 = ones(1, Ns);  % Reponse impulsionnelle du filtre de réception
n0 = Ns;            % Choix du t0 pour respecter le critère de Nyquist
M = 2;

% Sans bruit
    An = (2*bits - 1)';
    At = kron(An, [1, zeros(1, Ns-1)]); % Mapping

    x1 = filter(h, 1, At); % Mise en forme
    z1 = filter(hr1, 1, x1); % Filtre de réception

    echantillon = z1(n0:Ns:end); % Echantillonage
    bits_sortie1 = (sign(echantillon) + 1) / 2;
    TEB1 = sum(bits_sortie1' ~= bits) / n_bits;

    % Diagramme de l'oeil
    nexttile
    plot(reshape(z1,Ns,length(z1)/Ns));
    title('Diagramme de l''oeil');

    fprintf("TEB chaine 1 : " + TEB1 + "\n");

    nexttile
    stem([0:(n_bits*Ns-1)]*Te,At)
    ylim([-1.5, 1.5])
    hold on
    stem([0:(n_bits*Ns-1)]*Te, kron((2*bits_sortie1 - 1), [1, zeros(1, Ns-1)]))
    hold off
    xlabel("temps (s)")
    ylabel("Signal temporel")
    title('Comparaison des bits pour l''implantation optimale');
    legend('Bits de départ', 'Bits d''arrivée');

% Avec bruit
TEB1_bruit = zeros(1, length(EbN0));
z1_bruit = zeros(length(EbN0), length(z1));
for i = 1:length(EbN0)

    % Canal de propagation
    sigma2 = (mean(abs(x1).^2)*Ns)/(2*log2(M)*10^(EbN0(i)/10));
    bruit = sqrt(sigma2)*randn(1, length(x1));
    r1 = x1 + bruit;

    z1 = filter(hr1, 1, r1);
    z1_bruit(i, :) = z1;

    echantillon = z1(n0:Ns:end);
    bits_sortie = (sign(echantillon) + 1) / 2;
    TEB1_bruit(i) = sum(bits_sortie' ~= bits) / n_bits;
end

    % Diagramme de l'oeil pour deux valeurs Eb / N0 différentes
    nexttile
    plot(reshape(z1_bruit(2, :),Ns,length(z1_bruit(1, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 1');

    nexttile
    plot(reshape(z1_bruit(9, :),Ns,length(z1_bruit(9, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 8');

    % TEB Obtenu et théorique
    nexttile
    TEB1_theorique = qfunc(sqrt(2*(10.^(EbN0/10))));
    semilogy(EbN0,TEB1_bruit)
    hold on
    semilogy(EbN0,TEB1_theorique)
    hold off
    title("Comparaison entre le TEB obtenu et le TEB théorique")
    legend("TEB obtenu","TEB théorique")
    xlabel("Eb/N0 (en dB)")
    ylabel("TEB")


% Chaine 2 ---------------------------------------------------------
figure('name', 'Chaine 2')

Ts = Tb;            % Période symbole
Ns = Fe * Ts;       % Nombre d'échantillons par bits
h = ones(1, Ns);    % Reponse impulsionnelle du filtre de mise en forme
hr2 = ones(1, floor(Ns/2)); % Reponse impulsionnelle du filtre de réception
n0 = floor(Ns/2);   % Choix du t0 pour respecter le critère de Nyquist
M = 2;

% Sans bruit
    % Mapping
    An = (2*bits - 1)';
    At = kron(An, [1, zeros(1, Ns-1)]);

    x2 = filter(h, 1, At);
    z2 = filter(hr2, 1, x2);

    echantillon = z2(n0:Ns:end);
    bits_sortie2 = (sign(echantillon) + 1) / 2;
    TEB2 = sum(bits_sortie2' ~= bits) / n_bits;

    % Diagramme de l'oeil
    nexttile
    plot(reshape(z2,Ns,length(z2)/Ns));
    title('Diagramme de l''oeil');

    fprintf("TEB chaine 2 : " + TEB2 + "\n");
   
    nexttile
    stem([0:(n_bits*Ns-1)]*Te,At)
    ylim([-1.5, 1.5])
    hold on
    stem([0:(n_bits*Ns-1)]*Te, kron((2*bits_sortie2 - 1), [1, zeros(1, Ns-1)]))
    hold off
    xlabel("temps (s)")
    ylabel("Signal temporel")
    title('Comparaison des bits pour l''implantation optimale');
    legend('Bits de départ', 'Bits d''arrivée');
   
% Avec bruit
TEB2_bruit = zeros(1, length(EbN0));
z2_bruit = zeros(length(EbN0), length(z2));
for i = 1:length(EbN0)

    % Canal de propagation
    sigma2 = (mean(abs(x1).^2)*Ns)/(2*log2(M)*10^(EbN0(i)/10));
    bruit = sqrt(sigma2)*randn(1, length(x2));
    r2 = x2 + bruit;

    z2 = filter(hr2, 1, r2);
    z2_bruit(i, :) = z2;

    echantillon = z2(n0:Ns:end);
    bits_sortie = (sign(echantillon) + 1) / 2;
    TEB2_bruit(i) = sum(bits_sortie' ~= bits) / n_bits;
end

    % Diagramme de l'oeil pour deux valeurs Eb / N0 différentes
    nexttile
    plot(reshape(z2_bruit(2, :),Ns,length(z2_bruit(1, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 1');

    nexttile
    plot(reshape(z2_bruit(9, :),Ns,length(z2_bruit(9, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 8');

    % TEB Obtenu et théorique
    nexttile
    TEB2_theorique = qfunc(sqrt((10.^(EbN0/10))));
    semilogy(EbN0,TEB2_bruit)
    hold on
    semilogy(EbN0,TEB2_theorique)
    hold off
    title("Comparaison entre le TEB obtenu et le TEB théorique")
    legend("TEB obtenu","TEB théorique")
    xlabel("Eb/N0 (en dB)")
    ylabel("TEB")


% Chaine 3 ---------------------------------------------------------
figure('name', 'Chaine 3')

Ts = Tb;        % Période symbole
Ns = Fe * Ts;       % Nombre d'échantillons par bits
h = ones(1, Ns);    % Reponse impulsionnelle du filtre de mise en forme
hr3 = ones(1, Ns); % Reponse impulsionnelle du filtre de réception
n0 = Ns;        % Choix du t0 pour respecter le critère de Nyquist
M = 4;

% Sans bruit
    % Mapping
    LUT = [-3, -1, 3, 1];
    An = LUT(1+bi2de(reshape(bits, n_bits/2, 2), 'left-msb'));
    At = kron(An, [1, zeros(1, Ns-1)]);

    x3 = filter(h, 1, At);
    z3 = filter(hr3, 1, x3);

    echantillon = z3(n0:Ns:end);
    symboles = zeros(1,length(echantillon));
    symboles(echantillon > 2 * Ns) = 3;
    symboles(echantillon >= 0 & echantillon <= 2 * Ns) = 1;
    symboles(echantillon < -2 * Ns) = -3;
    symboles(echantillon >= -2 * Ns & echantillon < 0) = -1;

    [~, rank] = ismember(symboles, LUT);
    binary = de2bi(rank-1, 'left-msb');
    bits_sortie3 = reshape(binary,1,n_bits);
    TEB3 = sum(bits_sortie3' ~= bits) / n_bits;

    % Diagramme de l'oeil
    nexttile
    plot(reshape(z3,Ns,length(z3)/Ns));
    title('Diagramme de l''oeil');

    fprintf("TEB chaine 3 : " + TEB3 + "\n");

    nexttile
    stem([0:((n_bits*Ns/2)-1)]*Te,At)
    ylim([-3.5, 3.5])
    hold on
    stem([0:((n_bits*Ns/2)-1)]*Te, kron(symboles, [1, zeros(1, Ns-1)]))
    hold off
    xlabel("temps (s)")
    ylabel("Signal temporel")
    title('Comparaison des bits pour l''implantation optimale');
    legend('Bits de départ', 'Bits d''arrivée');

% Avec bruit
TEB3_bruit = zeros(1, length(EbN0));
z3_bruit = zeros(length(EbN0), length(z3));
for i = 1:length(EbN0)

    % Canal de propagation
    sigma2 = (mean(abs(x3).^2)*Ns)/(2*log2(M)*10^(EbN0(i)/10));
    bruit = sqrt(sigma2)*randn(1, length(x3));
    r3 = x3 + bruit;

    z3 = filter(hr3, 1, r3);
    z3_bruit(i, :) = z3;

    echantillon = z3(n0:Ns:end);
    symboles = zeros(1,length(echantillon));
    symboles(echantillon > 2 * Ns) = 3;
    symboles(echantillon >= 0 & echantillon <= 2 * Ns) = 1;
    symboles(echantillon < -2 * Ns) = -3;
    symboles(echantillon >= -2 * Ns & echantillon < 0) = -1;

    [~, rank] = ismember(symboles, LUT);
    binary = de2bi(rank-1, 'left-msb');
    bits_sortie = reshape(binary,1,n_bits);
    TEB3_bruit(i) = sum(bits_sortie' ~= bits) / n_bits;
end

    % Diagramme de l'oeil pour deux valeurs Eb/N0 différentes
    nexttile
    plot(reshape(z3_bruit(2, :),Ns,length(z3_bruit(1, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 1');

    nexttile
    plot(reshape(z3_bruit(9, :),Ns,length(z3_bruit(9, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 8');

    % TEB Obtenu et théorique
    nexttile
    TEB3_theorique = (3/4) *qfunc(sqrt((4/5)*(10.^(EbN0/10)))); 
    semilogy(EbN0,TEB3_bruit)
    hold on
    semilogy(EbN0,TEB3_theorique)
    hold off
    title("Comparaison entre le TEB obtenu et le TEB théorique")
    legend("TEB obtenu","TEB théorique")
    xlabel("Eb/N0 (en dB)")
    ylabel("TEB")

% Comparaison des chaines de transmission implantées
figure('name', "Comparaison des chaines de transmission implantées")

    % TEB des chaines 1 et 2
    nexttile
    semilogy(EbN0,TEB1_bruit)
    hold on
    semilogy(EbN0,TEB2_bruit)
    hold off
    title("Comparaison entre le TEB des chaines 1 et 2")
    legend("Chaine 1","Chaine 2")
    ylabel("TEB")

    % Efficacité de puissance chaines 1 et 2


    % TEB des chaines 1 et 3
    nexttile
    plot(TEB1_bruit)
    hold on
    plot(TEB3_bruit)
    hold off
    title("Comparaison entre le TEB des chaines 1 et 3")
    legend("Chaine 1","Chaine 3")
    ylabel("TEB")