library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_er_1octet1 is
  end test_er_1octet1;

architecture behavior of test_er_1octet1 is

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
  signal en : std_logic := '0';
  signal din : std_logic_vector(7 downto 0) := (others => '0');
  signal miso : std_logic := '0';

  --Outputs
  signal busy : std_logic;
  signal dout : std_logic_vector(7 downto 0);
  signal sclk : std_logic;
  signal mosi : std_logic;

  --References
  signal busy_ref : std_logic;
  signal dout_ref : std_logic_vector(7 downto 0);
  signal sclk_ref : std_logic;
  signal mosi_ref : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  m : er_1octet
  port map ( clk => clk,
             rst => reset,
             en => en,
             busy => busy,
             din => din,
             dout => dout,
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


  -- Stimulus process
  stim_proc: process
  begin                
    -- hold reset state for 100 ns.
    wait for 100 ns;  
    reset <= '1';

    wait for clk_period*10;

    -- insert stimulus here

    din <= "10110101";

    en <= '1';

    wait for clk_period;

    en <= '0';
    din <= (others => 'U');

    wait for 21*clk_period;

    din <= "00110100";

    en <= '1';

    wait for clk_period;

    en <= '0';
    din <= (others => 'U');

    wait;
  end process;

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
  -- pour vérifier si mosi, sclk et busy et dout sont corrects

  busy_ref <= '0' after 0 ps,
              '1' after 205000 ps,
              '0' after 355000 ps,
              '1' after 425000 ps,
              '0' after 575000 ps;

  dout_ref <= "UUUUUUUU" after 0 ps,
              "10011011" after 355000 ps,
              "10110011" after 575000 ps;

  mosi_ref <= 'U' after 0 ps,
              '1' after 205000 ps,
              '0' after 225000 ps,
              '1' after 245000 ps,
              '0' after 285000 ps,
              '1' after 305000 ps,
              '0' after 325000 ps,
              '1' after 345000 ps,
              '0' after 425000 ps,
              '1' after 465000 ps,
              '0' after 505000 ps,
              '1' after 525000 ps,
              '0' after 545000 ps;

  sclk_ref <= '1' after 0 ps,
              '0' after 205000 ps,
              '1' after 215000 ps,
              '0' after 225000 ps,
              '1' after 235000 ps,
              '0' after 245000 ps,
              '1' after 255000 ps,
              '0' after 265000 ps,
              '1' after 275000 ps,
              '0' after 285000 ps,
              '1' after 295000 ps,
              '0' after 305000 ps,
              '1' after 315000 ps,
              '0' after 325000 ps,
              '1' after 335000 ps,
              '0' after 345000 ps,
              '1' after 355000 ps,
              '0' after 425000 ps,
              '1' after 435000 ps,
              '0' after 445000 ps,
              '1' after 455000 ps,
              '0' after 465000 ps,
              '1' after 475000 ps,
              '0' after 485000 ps,
              '1' after 495000 ps,
              '0' after 505000 ps,
              '1' after 515000 ps,
              '0' after 525000 ps,
              '1' after 535000 ps,
              '0' after 545000 ps,
              '1' after 555000 ps,
              '0' after 565000 ps,
              '1' after 575000 ps;

  process(clk)
  begin
    if(falling_edge(clk)) then
      assert(mosi = mosi_ref) report "mosi incorrect (décalage ?)"
      severity error;
      assert(sclk = sclk_ref) report "sclk incorrect (décalage ?)"
      severity error;
      assert(busy = busy_ref) report "busy incorrect (décalage ?)"
      severity error;
      assert(dout = dout_ref) report "dout incorrect (décalage ?)"
      severity error;
    end if;
  end process;

end behavior;
