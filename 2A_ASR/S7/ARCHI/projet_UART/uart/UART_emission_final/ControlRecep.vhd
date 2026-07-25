library IEEE;
use IEEE.std_logic_1164.all;

-- Déclaration de l'entité ControlRecep
-- Cette entité représente un module de contrôle pour un récepteur UART.
entity ControlRecep is
    port (
        reset, clk, tmpClk : in std_logic;          -- Entrées : reset, horloge principale, horloge temporaire pour synchronisation
        read : in std_logic;                        -- Entrée : signal indiquant une demande de lecture des données reçues
        tmpRxD : in std_logic;                      -- Entrée : bit reçu en série
        FErr, OErr, DRdy : out std_logic;           -- Sorties : erreurs de trame (FErr), débordement (OErr), et données prêtes (DRdy)
        data : out std_logic_vector(7 downto 0)     -- Sortie : octet de données reçu
    );
end ControlRecep;

architecture ControlRecep_arch of ControlRecep is

    -- Définition des états possibles pour la machine à états
    type t_state is (r_start, r_data, r_par, r_stop, verif, isProcessed);
    signal state : t_state;  -- Signal pour stocker l'état courant de la machine à états

    -- Signaux internes pour les bits de parité, de stop, et de contrôle des données
    signal b_par, b_stop, par_expected : std_logic;
    signal tmpData : std_logic_vector(7 downto 0); -- Buffer temporaire pour stocker les données reçues
begin

    -- Processus principal, sensible à l'horloge et au signal de reset
    process (clk, reset)  
        variable cpt_data : natural; -- Compteur pour suivre le nombre de bits de données reçus
    begin
        -- Réinitialisation des signaux et de l'état
        if (reset = '0') then 
            par_expected <= '0';    -- Initialisation de la parité attendue
            cpt_data := 8;          -- Compteur de bits à recevoir (8 bits pour un octet)
            FErr <= '0';            -- Pas d'erreur de trame
            OErr <= '0';            -- Pas d'erreur de débordement
            DRdy <= '0';            -- Données pas encore prêtes
            state <= r_start;       -- Retour à l'état initial
        elsif (rising_edge(clk)) then
            -- Gestion des transitions d'états selon l'état courant
            case state is 
                when r_start => 
                    -- État de démarrage : attendre la synchronisation
                    FErr <= '0';
                    OErr <= '0';
                    DRdy <= '0';
                    if (tmpClk = '1') then 
                        par_expected <= '0';
                        cpt_data := 8;
                        state <= r_data; -- Transition vers la réception des données
                    end if;

                when r_data =>
                    -- État de réception des données : collecter les 8 bits
                    FErr <= '0';
                    OErr <= '0';
                    DRdy <= '0';
                    if (tmpClk = '1') then 
                        cpt_data := cpt_data - 1; -- Décrément du compteur
                        tmpData(cpt_data) <= tmpRxD; -- Stockage du bit reçu
                        par_expected <= tmpRxD xor par_expected; -- Mise à jour de la parité attendue
                        if (cpt_data = 0) then 
                            state <= r_par; -- Transition vers la réception de la parité
                        end if;
                    end if;

                when r_par => 
                    -- État de réception du bit de parité
                    FErr <= '0';
                    OErr <= '0';
                    DRdy <= '0';
                    if (tmpClk = '1') then 
                        b_par <= tmpRxD; -- Stockage du bit de parité reçu
                        state <= r_stop; -- Transition vers la réception du bit de stop
                    end if;

                when r_stop => 
                    -- État de réception du bit de stop
                    FErr <= '0';
                    OErr <= '0';
                    DRdy <= '0';
                    if (tmpClk = '1') then 
                        b_stop <= tmpRxD; -- Stockage du bit de stop
                        state <= verif;  -- Transition vers la vérification
                    end if;

                when verif =>
                    -- État de vérification : contrôle du bit de stop et de la parité
                    if (b_stop = '0' or not b_par = par_expected) then 
                        FErr <= '1'; -- Erreur si le bit de stop ou la parité ne correspond pas
                        state <= r_start; -- Retour à l'état initial
                    else 
                        DRdy <= '1'; -- Données prêtes
                        data <= tmpData; -- Transfert des données vers la sortie
                        state <= isProcessed; -- Transition vers l'état d'attente de traitement
                    end if;

                when isProcessed =>
                    -- État d'attente de traitement : attente de lecture ou détection d'erreur de débordement
                    DRdy <= '0';
                    if (read = '1') then 
                        state <= r_start; -- Lecture terminée, retour à l'état initial
                    else 
                        OErr <= '1'; -- Détection d'une erreur de débordement
                        state <= r_start; -- Retour à l'état initial
                    end if;
            end case;
        end if;
    end process;
end ControlRecep_arch;
