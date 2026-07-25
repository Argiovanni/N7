library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4Joystick is
  port (
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0);
    -- connect to joystick
    JA9 : in std_logic; -- MISO
    JA7,JA8,JA10 : out std_logic -- SS,MOSI,SCLK

  );
end Nexys4Joystick;

architecture synthesis of Nexys4Joystick is

  -- rappel du (des) composant(s)
  component MasterJoystick
    port ( rst      : in std_logic;
           clk      : in std_logic;
           en       : in std_logic;
           led1     : in std_logic;
           led2     : in std_logic;
           miso     : in std_logic;
           ss       : out std_logic;
           sclk     : out std_logic;
           mosi     : out std_logic;
           vX       : out std_logic_vector (9 downto 0);
           vY       : out std_logic_vector(9 downto 0);
           val_btn1 : out std_logic;
           val_btn2 : out std_logic;
           val_btnJ : out std_logic;
           busy     : out std_logic);
  end component;

  component All7Segments 
    Port ( clk   : in  std_logic;
           reset : in std_logic;
           e0    : in std_logic_vector (3 downto 0);
           e1    : in std_logic_vector (3 downto 0);
           e2    : in std_logic_vector (3 downto 0);
           e3    : in std_logic_vector (3 downto 0);
           e4    : in std_logic_vector (3 downto 0);
           e5    : in std_logic_vector (3 downto 0);
           e6    : in std_logic_vector (3 downto 0);
           e7    : in std_logic_vector (3 downto 0);
           an    : out std_logic_vector (7 downto 0);
           ssg   : out std_logic_vector (7 downto 0));
  end component;
  
  component diviseurClk
    generic(facteur : natural);
    port (
    clk, reset : in  std_logic;
    nclk       : out std_logic);
  end component;

  signal d_clk : STD_LOGIC;
  --Inputs
  signal x_axis : std_logic_vector(9 downto 0) := (others => '0');  
  signal y_axis : std_logic_vector(9 downto 0) := (others => '0');
  -- Shared
  signal reset     : std_logic;

begin

  -- valeurs des sorties (à modifier)
  -- 16 leds éteintes
  led(15 downto 4) <= (others => '0');
  
  reset <= not btnC;

  -- connexion du (des) composant(s) avec les ports de la carte
  Inst_DivClk : diviseurClk
  generic map ( 100 )
  port map ( clk => mclk, reset => reset, nclk => d_clk );

  Inst_MJ : MasterJoystick
  port map ( reset, d_clk, swt(0), swt(1), swt(2), 
             JA9, JA7, JA10, JA8,
             x_axis, y_axis, led(1), led(2), led(3),
             led(0)
             );

  Inst_A7sg : All7Segments
  port map ( mclk, reset, x_axis(3 downto 0), x_axis(7 downto 4), "00"&x_axis(9 downto 8),
             "0000","0000", y_axis(3 downto 0), y_axis(7 downto 4), "00"&y_axis(9 downto 8),
              an, ssg
            );

end synthesis;
