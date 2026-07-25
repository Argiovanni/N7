library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4 is
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
    ssg : out std_logic_vector (7 downto 0)
  );
end Nexys4;

architecture synthesis of Nexys4 is

  COMPONENT diviseurClk1Hz
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;

  COMPONENT clkUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		enableTX : OUT std_logic;
		enableRX : OUT std_logic
		);
	END COMPONENT;

  signal clk, rst : std_logic;	

begin

  -- valeurs des sorties

  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  ssg <= (others => '1');
  -- aucun afficheur sélectionné
  an(7 downto 0) <= (others => '1');
  -- 16 leds éteintes
  led(15 downto 2) <= (others => '0');

  rst <= not btnC;

  -- connexion du (des) composant(s) avec les ports de la carte
  
  Inst_diviseurClk1Hz: diviseurClk1Hz PORT MAP(
		clk => mclk,
		reset => rst,
		nclk => clk
	);
	
	Inst_clkUnit: clkUnit PORT MAP(
		clk => clk,
		reset => rst,
		enableTX => led(1),
		enableRX => led(0)
	);

    
end synthesis;
