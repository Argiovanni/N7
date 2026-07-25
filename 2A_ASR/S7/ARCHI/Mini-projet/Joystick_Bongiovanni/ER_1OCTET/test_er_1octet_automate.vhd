library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_er_1octet2 is
  end test_er_1octet2;

architecture behavior of test_er_1octet2 is

  component er_1octet
    port ( rst : in std_logic;
           clk : in std_logic;
           en : in std_logic;
           din : in std_logic_vector (7 downto 0);
           miso : in std_logic;
           sclk : out std_logic;
           mosi : out std_logic;
           dout : out std_logic_vector (7 downto 0);
           busy : out std_logic);
  end component;

  --Inputs
  signal clk : std_logic := '0';
  signal reset : std_logic := '0';
  signal en_er : std_logic := '0';
  signal din_er : std_logic_vector(7 downto 0) := (others => '0');
  signal miso : std_logic := '0';

  --Outputs
  signal busy_er : std_logic;
  signal dout_er : std_logic_vector(7 downto 0);
  signal sclk : std_logic;
  signal mosi : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  -- types
  type t_etat is (debut, attente_active, echange_octet, fin);
        
  -- signaux internes   
  signal etat : t_etat;

  signal mosi_ref : std_logic;
  signal sclk_ref : std_logic;
  signal busy_ref : std_logic;
  signal dout_ref : std_logic_vector(7 downto 0);

begin

  m : er_1octet
  port map ( clk => clk,
             rst => reset,
             en => en_er,
             busy => busy_er,
             din => din_er,
             dout => dout_er,
             sclk => sclk,
             miso => miso,
             mosi => mosi
           );

  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  reset <= '0', '1' after 100 ns;

  -- process permettant d'échanger 2 octets
  stim_proc: process(clk, reset)
    -- variables 
    variable cpt_att : natural;
    variable cpt_octet : natural;
  begin
    if(reset = '0') then
      cpt_octet := 0;
      en_er <= '0';
      din_er <= (others => 'U');
      etat <= debut;
    elsif(rising_edge(clk)) then

      case  etat is

        when debut =>
          -- attente de 10 cycles de l'horloge
          -- avant le premier octet
          cpt_att := 10;
          cpt_octet := 0;
          etat <= attente_active;

        when attente_active => 
          cpt_att := cpt_att - 1;
          if(cpt_att = 0) then
            -- on a attendu assez longtemps

            -- valeur de l'octet envoyé
            if(cpt_octet = 0) then
              din_er <= "10110101";
            else
              din_er <= "01010100";
            end if;
            -- on lance l'échange d'un octet en activant
            -- le sous-composant
            en_er <= '1';
            etat <= echange_octet;
          end if;

        when echange_octet => 
          -- on rabaisse l'ordre passé au sous-composant
          en_er <= '0';
          din_er <= (others => 'U');

          if(en_er = '0' and busy_er ='0') then
            -- échange d'1 octet terminé

            -- on prépare la suite
            if(cpt_octet = 0) then
              -- il reste des octets à transmettre
              cpt_octet := cpt_octet + 1;
              -- attente de 5 cycles entre les deux octets
              cpt_att := 5;
              etat <= attente_active;
            else
              -- on a envoyé 2 octets, c'est fini
              etat <= fin;
            end if;

          end if;

        when fin => null;

      end case;

    end if;
  end process;

  -- process qui génère le signal miso
  genere_miso : process(clk, reset)
    variable cpt : natural;

  begin
    if(reset = '0') then
      miso <= '0';
      cpt := 0;
    elsif(falling_edge(clk)) then
      cpt := (cpt + 1) mod 7;
      if(cpt < 3) then
        miso <= '0';
      else
        miso <= '1';
      end if;                  
    end if;
  end process genere_miso;

  --
  -- pour vérifier si mosi, sclk, busy et dout sont corrects
busy_ref <= '0' after 0 ps,
           '1' after 215000 ps,
           '0' after 365000 ps,
           '1' after 435000 ps,
           '0' after 585000 ps;

dout_ref <= "UUUUUUUU" after 0 ps,
           "10110011" after 365000 ps,
           "00110110" after 585000 ps;

mosi_ref <= 'U' after 0 ps,
        '1' after 215000 ps,
        '0' after 235000 ps,
        '1' after 255000 ps,
        '0' after 295000 ps,
        '1' after 315000 ps,
        '0' after 335000 ps,
        '1' after 355000 ps,
        '0' after 435000 ps,
        '1' after 455000 ps,
        '0' after 475000 ps,
        '1' after 495000 ps,
        '0' after 515000 ps,
        '1' after 535000 ps,
        '0' after 555000 ps;

sclk_ref <= '1' after 0 ps,
        '0' after 215000 ps,
        '1' after 225000 ps,
        '0' after 235000 ps,
        '1' after 245000 ps,
        '0' after 255000 ps,
        '1' after 265000 ps,
        '0' after 275000 ps,
        '1' after 285000 ps,
        '0' after 295000 ps,
        '1' after 305000 ps,
        '0' after 315000 ps,
        '1' after 325000 ps,
        '0' after 335000 ps,
        '1' after 345000 ps,
        '0' after 355000 ps,
        '1' after 365000 ps,
        '0' after 435000 ps,
        '1' after 445000 ps,
        '0' after 455000 ps,
        '1' after 465000 ps,
        '0' after 475000 ps,
        '1' after 485000 ps,
        '0' after 495000 ps,
        '1' after 505000 ps,
        '0' after 515000 ps,
        '1' after 525000 ps,
        '0' after 535000 ps,
        '1' after 545000 ps,
        '0' after 555000 ps,
        '1' after 565000 ps,
        '0' after 575000 ps,
        '1' after 585000 ps;


  process(clk)
  begin
    if(falling_edge(clk)) then
      assert(mosi = mosi_ref) report "mosi faux"
      severity error;
      assert(sclk = sclk_ref) report "sclk faux"
      severity error;
      assert(busy_er = busy_ref) report "busy faux"
      severity error;
      assert(dout_er = dout_ref) report "dout faux"
      severity error;
    end if;
  end process;

end behavior;
