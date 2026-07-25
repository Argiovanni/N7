library IEEE;
use IEEE.std_logic_1164.all;

-- Déclaration de l'entité RxUnit
-- Cette entité regroupe un compteur (Counter16) et une unité de contrôle (ControlRecep) 
-- pour gérer la réception des données série (RxD).
entity RxUnit is
  port (
    clk, reset       : in  std_logic;                  -- Entrées : horloge et reset
    enable           : in  std_logic;                  -- Entrée : signal d'activation globale
    read             : in  std_logic;                  -- Entrée : signal de lecture
    rxd              : in  std_logic;                  -- Entrée : signal série reçu
    data             : out std_logic_vector(7 downto 0); -- Sortie : octet de données reçues
    Ferr, OErr, DRdy : out std_logic                   -- Sorties : erreurs et indicateur de données prêtes
  );
end RxUnit;

architecture RxUnit_arch of RxUnit is

  -- Déclaration du composant Counter16
  -- Compteur utilisé pour générer un signal d'horloge temporaire (tmpClk) à partir de RxD.
  component Counter16 is
    port (
        reset   : in  std_logic;      -- Entrée : signal de reset
        enable  : in  std_logic;      -- Entrée : signal d'activation
        RxD     : in  std_logic;      -- Entrée : signal série reçu
        tmpClk  : out std_logic;      -- Sortie : horloge temporaire générée
        tmpRxD  : out std_logic       -- Sortie : signal série synchronisé
    );
  end component;

  -- Déclaration du composant ControlRecep
  -- Gère la réception des données, vérifie les erreurs, et fournit les données reçues.
  component ControlRecep is
    port (
      reset, clk, tmpClk : in  std_logic;               -- Entrées : reset, horloge principale, horloge temporaire
      read               : in  std_logic;               -- Entrée : signal de lecture
      tmpRxD             : in  std_logic;               -- Entrée : signal série synchronisé
      FErr, OErr, DRdy   : out std_logic;               -- Sorties : erreurs et indicateur de données prêtes
      data               : out std_logic_vector(7 downto 0) -- Sortie : octet de données reçues
    );
  end component;

  -- Signaux internes pour relier les deux composants
  signal tmpClk : std_logic;  -- Horloge temporaire générée par Counter16
  signal tmpRxD : std_logic;  -- Signal série synchronisé généré par Counter16

begin

  -- Instance du composant Counter16
  -- Génère une horloge temporaire `tmpClk` et un signal synchronisé `tmpRxD` à partir de `rxd`.
  inst_Counter16 : Counter16
    PORT MAP (
      reset   => reset,      -- Relie le signal global de reset
      enable  => enable,     -- Relie le signal global d'activation
      RxD     => rxd,        -- Relie l'entrée série reçue
      tmpClk  => tmpClk,     -- Relie la sortie de l'horloge temporaire
      tmpRxD  => tmpRxD      -- Relie la sortie du signal synchronisé
    );

  -- Instance du composant ControlRecep
  -- Gère la réception des données et les vérifications d'erreurs.
  inst_ControlRecep : ControlRecep
    PORT MAP (
      reset   => reset,      -- Relie le signal global de reset
      clk     => clk,        -- Relie l'horloge principale
      tmpClk  => tmpClk,     -- Relie l'horloge temporaire générée par Counter16
      read    => read,       -- Relie le signal de lecture
      tmpRxD  => tmpRxD,     -- Relie le signal synchronisé de Counter16
      FErr    => FErr,       -- Relie la sortie de l'erreur de trame
      OErr    => OErr,       -- Relie la sortie de l'erreur de débordement
      DRdy    => DRdy,       -- Relie la sortie indiquant que les données sont prêtes
      data    => data        -- Relie la sortie des données reçues
    );

end RxUnit_arch;
