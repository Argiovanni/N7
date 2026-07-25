library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is
begin
  -- enableRX vaut clk quand reset = '1' sinon il vaut '0'
  enableRX <= (reset and clk);
  
  process(clk, reset)
    variable ticks : natural := 0; -- Compteur de cycles d'horloge.
  begin
    if (reset = '0') then
      enableTX <= '0'; -- Désactive la transmission.
      ticks := 0;      -- Réinitialise le compteur.
    
    elsif (rising_edge(clk)) then
      -- Au 16eme cycles d'horloge :
      if (ticks > 14) then
        ticks := 0;      -- Réinitialise le compteur à 0.
        enableTX <= '1'; -- Active la transmission pendant un cycle.
      else
        ticks := ticks + 1; -- Incrémente le compteur de 1.
        enableTX <= '0';    -- Maintient la transmission désactivée.
      end if;

    end if; 

  end process; 
end behavorial;

