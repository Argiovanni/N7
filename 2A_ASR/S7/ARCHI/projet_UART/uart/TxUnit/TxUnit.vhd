library IEEE;
use IEEE.std_logic_1164.all;


entity TxUnit is
  port (
    clk, reset : in std_logic;  -- Entrée de l'horloge et du signal de reset
    enable : in std_logic;      -- Signal d'activation
    ld : in std_logic;          -- Signal de chargement
    txd : out std_logic;        -- Sortie pour la transmission de données
    regE : out std_logic;       -- Sortie pour indiquer si le registre est vide
    bufE : out std_logic;       -- Sortie pour indiquer si le buffer est vide
    data : in std_logic_vector(7 downto 0)  -- Données d'entrée (8 bits)
  );
end TxUnit;

architecture behavorial of TxUnit is
  -- Définition des différents états possibles de la machine à états
  type t_state is (idle, load, init, transmit, ending);
  signal state : t_state;  -- Signal pour stocker l'état courant
  signal bufT : std_logic_vector(7 downto 0);  -- buffer pour les données à transmettre
  signal regT : std_logic_vector(7 downto 0);  -- Registre pour stocker les données après chargement depuis le buffer
  signal par : std_logic;  -- Bit de parité
  signal bufE_sig : std_logic;  -- Signal pour lire l'état du buffer (car il est en ecriture seul sinon)
begin
  -- Affectation du signal bufE à la variable interne bufE_sig pour la raison précédente
  bufE <= bufE_sig;

  process (clk, reset)  
    variable nb_bit : natural;  -- Variable pour compter les bits restants à transmettre
  begin
    if (reset = '0') then 
      -- Réinitialisation de tous les signaux
      txd <= '1';              -- Transmission par défaut est inactivée (haut)
      bufE_sig <= '1';         -- buffer est vide
      par <= '0';              -- Parité est réinitialisée à 0
      regE <= '1';             -- Registre est vide
      state <= idle;           -- L'état initial est idle
    elsif (rising_edge(clk)) then 
      case state is 
        when idle => 
          -- Lorsque l'état est "idle" (attente)            
          par <= '0';  -- Réinitialiser la parité
          if (ld = '1') then -- Instruction de chargement du buffer
            bufT <= data;  -- Charger les données dans le buffer
            bufE_sig <= '0';  -- Mettre a jour -> buffer plein
            state <= load;  -- Passer à l'état "load" (chargement)
          end if;
          
        when load =>
          -- Lors de l'état "load" (chargement des données dans le registre)
          regT <= bufT;  -- Charger les données dans le registre depuis le buffer
          regE <= '0';   -- Le registre est plein
          bufE_sig <= '1';  -- Le buffer est vide
          state <= init;  -- Passer à l'état "init" (initialisation)
          
        when init => 
          -- Lors de l'état "init" (initialisation de la transmission)
          if (bufE_sig = '1' and ld ='1') then -- Si des données peuvent être chargé en avance dans le buffer
            bufT <= data;  -- Charger de nouvelles données si nécessaire
            bufE_sig <= '0';  -- Le buffer est maintenant plein
          end if;
          if (enable = '1') then 
            txd <= '0';   -- Démarrer la transmission (le premier bit est à 0)
            nb_bit := 8;  -- Initialiser le nombre de bits restants à 8
            state <= transmit;  -- Passer à l'état "transmit"
          end if;
          
        when transmit => 
          -- Lors de l'état "transmit" (transmission des données)
          if (bufE_sig = '1' and ld ='1') then -- Si des données peuvent être chargé en avance dans le buffer
            bufT <= data;  -- Charger de nouvelles données si nécessaire
            bufE_sig <= '0';  -- Le buffer est maintenant plein
          end if;
          -- Transmission de la charge utile
          if (enable = '1' and nb_bit > 0) then 
            -- Si l'activation est active et qu'il reste des bits à transmettre
            nb_bit := nb_bit - 1;  -- Décrémenter le nombre de bits restants
            txd <= regT(nb_bit);  -- Transmettre le bit actuel
            par <= par xor regT(nb_bit);  -- Mettre à jour la parité
          -- Transmission du contrôle (i.e bit de parité)
          elsif (enable = '1' and nb_bit = 0) then
            -- Lorsque tous les bits ont été transmis
            txd <= par;  -- Transmettre le bit de parité
            regE <= '1';  -- Indiquer que le registre est terminé
            state <= ending;  -- Passer à l'état "ending"
          end if;
          
        when ending => 
          -- Lors de l'état "ending" (fin de la transmission)
          if (bufE_sig = '1' and ld ='1') then -- Si des données peuvent être chargé en avance dans le buffer
            bufT <= data;  -- Charger de nouvelles données si nécessaire
            bufE_sig <= '0';  -- Le buffer est maintenant plein
          -- end if; -- Tout dans le même if pour être sur que la modification des sinaux soit pis en compte pour la suite
          elsif (enable = '1' and bufE_sig = '1') then 
            txd <= '1';  -- Mettre txd à 1 (inactivité de la ligne de transmission)
            par <= '0';
            state <= idle;  -- Revenir à l'état "idle" (attente)
          elsif (enable = '1' and bufE_sig = '0') then -- Si on a au préalable charger une valeur dans le buffer
            txd <= '1';  -- Mettre txd à 1 (inactivité)
            par <= '0';
            state <= load;  -- Revenir à l'état "load" pour charger de nouvelles données
          end if;
      end case;
    end if;

  end process;
end behavorial;
