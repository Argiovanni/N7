library IEEE;
use IEEE.std_logic_1164.all;

entity ctrlUnit is
  
  port (
    clk, reset       : in  std_logic;
    rd, cs           : in  std_logic;
    DRdy, FErr, OErr : in  std_logic;
    BufE, RegE       : in  std_logic;
    IntR             : out std_logic;
    IntT             : out std_logic;
    ctrlReg          : out std_logic_vector(7 downto 0));

end ctrlUnit;

architecture ctrlUnit_arch of ctrlUnit is

  signal registreC : std_logic_vector(7 downto 0);

begin 

  ctrlReg <= registreC when (rd = '0' and cs ='0') else "11110000";

  ctrlProcess: process (clk, reset)

  begin
    if reset = '0' then

      IntR <= '1';
      IntT <= '1';
      registreC <= "11110000";

    elsif clk'event and clk = '1' then

      if DRdy = '0' then
        IntR <= '1';
        registreC(2) <= '0';
      elsif DRdy = '1' and FErr = '0' and OErr = '0'  then
        IntR <= '0';
        registreC(2) <= '1';
      end if;
       
      if (BufE = '1' or RegE = '1') then
        IntT <= '0';
        registreC(3) <= '1';
      else
        IntT <= '1';
        registreC(3) <= '0';
      end if;
       
      registreC(1) <= FErr;
      registreC(0) <= OErr;

    end if;

  end process ctrlProcess;

end ctrlUnit_arch;
