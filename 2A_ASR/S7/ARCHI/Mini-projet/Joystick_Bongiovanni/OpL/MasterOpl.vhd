library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MasterOpl is
  port ( rst : in std_logic;
         clk : in std_logic;
         en : in std_logic;
         v1 : in std_logic_vector (7 downto 0);
         v2 : in std_logic_vector(7 downto 0);
         miso : in std_logic;
         ss   : out std_logic;
         sclk : out std_logic;
         mosi : out std_logic;
         val_xor : out std_logic_vector (7 downto 0);
         val_and : out std_logic_vector (7 downto 0);
         val_or : out std_logic_vector (7 downto 0);
         busy : out std_logic);
end MasterOpl;

architecture behavior of MasterOpl is
  
  component er_1octet
  port ( rst : in std_logic ;
         clk : in std_logic ;
         en : in std_logic ;
         din : in std_logic_vector (7 downto 0) ;
         miso : in std_logic ;
         sclk : out std_logic ;
         mosi : out std_logic ;
         dout : out std_logic_vector (7 downto 0) ;
         busy : out std_logic) ;
  end component;

  type t_etat is (idle, sync10, oper, sync3);
  signal etat : t_etat;
  signal en_com : std_logic; -- enable er_1octet
  signal din : std_logic_vector (7 downto 0);
  signal dout : std_logic_vector (7 downto 0);
  signal er_busy : std_logic; -- indicate if er1octet is busy

begin
  inst_er1oct : er_1octet port map( rst, clk, en_com, din, miso, sclk, mosi, dout, er_busy);

  process (clk, rst)
    variable nb_cycle : natural; -- used for synchro
    -- indicate wich bytes is sent, should only be 0,1 or 2
    variable nb_octet : natural;
    begin
    if (rst = '0') then
      etat <= idle;
      ss <= '1';
      busy <= '0';
    elsif (rising_edge(clk)) then
      case( etat ) is
        when IDLE =>
          if (en = '1') then
            ss <= '0';
            busy <= '1';
            nb_cycle := 0;
            etat <= sync10;
          end if ;
        
        when sync10 =>
        if nb_cycle < 10 then 
          -- on attend 10 tours d'horloge
          nb_cycle := nb_cycle +1;
        else
          nb_cycle :=0;
          din <= v1; -- we want to send v1
          en_com <= '1'; -- enable communication
          nb_octet := 0;
          etat <= oper;
        end if ;

        when oper =>
        -- stop "communication signal" and wait for Er1_oct to finnish his task
          en_com <= '0'; 
          if (er_busy = '0' and en_com = '0') then -- when ER1octet is over
          case( nb_octet ) is
            when 0 =>
              val_xor <= dout; -- recup val_xor
              etat <= sync3;
            when 1 =>
              val_and <= dout; -- recup val_and
              etat <= sync3;
            when others =>
              val_or <= dout; -- recup val_or
              ss <= '1';
              busy <= '0';
              etat <= idle;
          end case ;
          end if;
        
        when sync3 =>
          if nb_cycle < 3 then 
            -- on attend 3 tours d'horloge
            nb_cycle := nb_cycle +1;
          else
            nb_cycle :=0;
            nb_octet := nb_octet +1; -- indicate next byte
            din <= v2; -- send v2
            en_com <= '1'; -- enable communication
            etat <= oper;
          end if ;
      end case ;
    end if;
  end process;
end behavior;
