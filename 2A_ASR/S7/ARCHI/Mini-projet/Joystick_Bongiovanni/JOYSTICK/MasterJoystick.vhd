library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MasterJoystick is
    port ( rst : in std_logic;
           clk : in std_logic;
           en : in std_logic;
           led1 : in std_logic;
           led2 : in std_logic;
           miso : in std_logic;
           ss   : out std_logic;
           sclk : out std_logic;
           mosi : out std_logic;
           vX : out std_logic_vector (9 downto 0);
           vY : out std_logic_vector(9 downto 0);
           val_btn1 : out std_logic;
           val_btn2 : out std_logic;
           val_btnJ : out std_logic;
           busy : out std_logic );
end MasterJoystick;

architecture behavior of MasterJoystick is
  component er_1octet
  port ( rst : in std_logic;
         clk : in std_logic;
         en : in std_logic;
         din : in std_logic_vector (7 downto 0);
         miso : in std_logic;
         sclk : out std_logic;
         mosi : out std_logic;
         dout : out std_logic_vector (7 downto 0);
         busy : out std_logic );
  end component;

  type t_etat is (idle, syncInit, oper, sync);
  signal etat : t_etat;
  signal en_com : std_logic; -- enable er_1octet
  signal din : std_logic_vector (7 downto 0);
  signal dout : std_logic_vector (7 downto 0);
  signal er_busy : std_logic; -- indicate if er_1octet is busy

  begin
    inst_er1oct : er_1octet port map( rst, clk, en_com, din, miso, sclk, mosi, dout, er_busy);
    process (clk, rst)
        variable nb_cycle : natural;
        variable fst_oct : natural; -- indicate wich byte is received 
        begin
        if (rst = '0') then
            etat <= idle;
            ss <= '1';
            busy <= '0';
        elsif (rising_edge(clk)) then
            case (etat) is
                when idle =>
                    if (en = '1') then
                        ss <= '0';
                        busy <= '1';
                        nb_cycle := 0;

                        -- construction octet cmd allumage led
                        din(7 downto 2) <= "100000";
                        din(1) <= led1;
                        din(0) <= led2;

                        etat <= syncInit;
                    end if ;

                when syncInit =>
                    if nb_cycle < 15 then 
                        -- on attend 15 tours d'horloge
                        nb_cycle := nb_cycle +1;
                    else
                        nb_cycle :=0;
                        en_com <= '1'; -- enable communication
                        fst_oct := 0;
                        etat <= oper;
                    end if;

                when oper =>
                    -- stop "communication signal" and wait for Er1_oct to finnish his task
                    en_com <= '0'; 
                    if (er_busy = '0' and en_com = '0') then -- when ER1octet is over
                    case( fst_oct ) is
                        -- fst_oct is the byte that's just been received (from 0 to 4)
                        when 0 =>
                            vX(7 downto 0) <= dout; -- X_axis lower byte
                            etat <= sync;
                        when 1 =>
                            vX(9 downto 8) <= dout(1 downto 0); -- X_axis two least significant bits of the upper byte
                            etat <= sync;
                        when 2 =>
                            vY(7 downto 0) <= dout;  -- Y_axis lower byte
                            etat <= sync;
                        when 3 =>
                            vY(9 downto 8) <= dout(1 downto 0); -- Y_axis two least significant bits of the upper byte
                            etat <= sync;
                        when others => -- button state (pressed or not)
                            val_btnJ <= dout(0); 
                            val_btn1 <= dout(1);
                            val_btn2 <= dout(2);
                            -- reset ss and busy before return to idle state
                            ss <= '1';
                            busy <= '0';
                            etat <= idle;
                    end case;
                    end if;
        
                when sync =>
                    if nb_cycle < 10 then 
                        -- on attend 10 tours d'horloge
                        nb_cycle := nb_cycle +1;
                    else
                        nb_cycle :=0;
                        en_com <= '1'; -- enable communication
                        fst_oct := fst_oct +1; -- look at next byte
                        etat <= oper;
                    end if;

            end case;
        end if;
    end process;
end behavior;