library IEEE;
use IEEE.std_logic_1164.all;

entity Counter16 is
    port (
        reset : in std_logic;
        enable : in std_logic;
        RxD : in std_logic;
        tmpClk : out std_logic;
        tmpRxD : out std_logic
    );
end Counter16;

architecture Counter16_arch of Counter16 is
    type t_state is (idle, count, pulse);
    signal state : t_state;  -- Signal pour stocker l'état courant
begin
    tmpRxd <= RxD;

    process (enable, reset)  
        variable cpt : natural;
        variable cptBit : natural;
    begin
        if (reset = '0') then 
            cpt := 6;
            cptBit := 11;
            tmpClk <= '0';
        elsif (rising_edge(enable)) then
            case state is 
                when idle =>
                    tmpClk <= '0';
                    if (RxD = '0') then 
                        cpt := 8;
                        cptBit := 11;
                        state <= count;
                    end if;
                when count => 
                    if (cpt = 0) then 
                        cpt := 15;
                        tmpClk <= '1';
                        cptBit := cptBit - 1;
                        state <= pulse;
                    else 
                        cpt := cpt - 1;
                        tmpClk <= '0';
                    end if;
                when pulse =>
                    tmpClk <= '0';
                    if (cptBit = 0) then 
                        state <= idle;
                    else 
                        cpt := cpt - 1;
                        state <= count;
                    end if;
            end case;
        end if;
    end process;
end Counter16_arch;