library IEEE;
use IEEE.std_logic_1164.all;

entity UARTunit is
  port (
    clk, reset : in  std_logic;
    cs, rd, wr : in  std_logic;
    RxD        : in  std_logic;
    TxD        : out std_logic;
    IntR, IntT : out std_logic;         
    addr       : in  std_logic_vector(1 downto 0);
    data_in    : in  std_logic_vector(7 downto 0);
    data_out   : out std_logic_vector(7 downto 0));
end UARTunit;


architecture UARTunit_arch of UARTunit is

  component TxUnit is
    port (
      clk, reset : in std_logic;  -- Entrée de l'horloge et du signal de reset
      enable : in std_logic;      -- Signal d'activation
      ld : in std_logic;          -- Signal de chargement
      txd : out std_logic;        -- Sortie pour la transmission de données
      regE : out std_logic;       -- Sortie pour indiquer si le registre est vide
      bufE : out std_logic;       -- Sortie pour indiquer si le buffer est vide
      data : in std_logic_vector(7 downto 0)  -- Données d'entrée (8 bits)
    );
  end component;

  component ctrlUnit is
    port (
      clk, reset       : in  std_logic;
      rd, cs           : in  std_logic;
      DRdy, FErr, OErr : in  std_logic;
      BufE, RegE       : in  std_logic;
      IntR             : out std_logic;
      IntT             : out std_logic;
      ctrlReg          : out std_logic_vector(7 downto 0)
    );
  end component;

  component clkUnit is
    port (
      clk, reset : in  std_logic;
      enableTX   : out std_logic;
      enableRX   : out std_logic
    );    
  end component;

  component RxUnit is
    port (
      clk, reset       : in  std_logic;
      enable           : in  std_logic;
      read             : in  std_logic;
      rxd              : in  std_logic;
      data             : out std_logic_vector(7 downto 0);
      Ferr, OErr, DRdy : out std_logic
    );
  end component;

  signal lecture, ecriture : std_logic;
  signal donnees_recues : std_logic_vector(7 downto 0);
  signal registre_controle : std_logic_vector(7 downto 0);

  signal enableTX : std_logic;
  signal enableRX : std_logic;

  signal regE : std_logic;
  signal bufE : std_logic;

  signal Ferr, OErr, DRdy : std_logic;

  begin  -- UARTunit_arch

    lecture <= '1' when cs = '0' and rd = '0' else '0';
    ecriture <= '1' when cs = '0' and wr = '0' else '0';
    data_out <= donnees_recues when lecture = '1' and addr = "00"
                else registre_controle when lecture = '1' and addr = "01"
                else "00000000";
  

    inst_clkUnit: clkUnit PORT MAP (
      clk => clk,
      reset => reset,
      enableTX => enableTX,
      enableRX => enableRX
    );

    inst_TxUnit : TxUnit PORT MAP (
      clk => clk,
      reset => reset,
      enable => enableTX,
      ld => ecriture,
      txd => TxD,
      data => data_in,
      regE => regE,
      bufE => bufE
    );

    inst_RxUnit : RxUnit PORT MAP (
      clk => clk,
      reset => reset,
      enable => enableRX,
      read => ecriture,
      rxd => RxD,
      data => donnees_recues,
      Ferr => Ferr,
      OErr => OErr,
      DRdy => DRdy
    );

    inst_CtrlUnit : CtrlUnit PORT MAP (
      clk => clk,
      reset => reset,
      rd => rd,
      cs => cs,
      DRdy => DRdy,
      FErr => FErr,
      OErr => OErr,
      RegE => regE,
      BufE => bufE,
      IntR => IntR,
      IntT => IntT,
      ctrlReg => registre_controle
    );

  end UARTunit_arch;
