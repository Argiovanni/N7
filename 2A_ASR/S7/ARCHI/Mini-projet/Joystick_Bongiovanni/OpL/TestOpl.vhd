-- fichier à écraser avec le fichier de test généré par ISE (New Source)
-- le nom du composant de test doit être TestOpl (respect minuscules/majuscules)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TestOpl is
  end TestOpl;

architecture behavior of TestOpl is

    component MasterOpl
    port ( 
        rst : in std_logic;
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
    end component;

    component SlaveOpl
    port(
        sclk : in  std_logic;
        mosi : in  std_logic;
        miso : out std_logic;
        ss   : in  std_logic);
    end component;

  --Inputs
  signal clk : std_logic := '0';
  signal reset : std_logic := '0';
  signal en_mtr : std_logic := '0';
  signal v1_mtr : std_logic_vector(7 downto 0) := (others => '0');  
  signal v2_mtr : std_logic_vector(7 downto 0) := (others => '0');

  --Outputs
  signal busy_mtr : std_logic;
  signal v_xor : std_logic_vector(7 downto 0);
  signal v_or : std_logic_vector(7 downto 0);
  signal v_and : std_logic_vector(7 downto 0);
  
  -- Shared
  signal ss_test   : std_logic;
  signal sclk_test : std_logic;
  signal mosi_test : std_logic;
  signal miso_test : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  -- -- References
  -- signal busy_ref : std_logic;
  -- signal xor_ref : std_logic_vector(7 downto 0);
  -- signal or_ref : std_logic_vector(7 downto 0);
  -- signal and_ref : std_logic_vector(7 downto 0);

begin

  master : MasterOpl
    port map(
      reset, clk, en_mtr, v1_mtr, v2_mtr, 
      miso_test, ss_test, sclk_test,
      mosi_test, v_xor, v_and, v_or, busy_mtr
    );

  slave : SlaveOpl
    port map(
      sclk_test, mosi_test, 
      miso_test, ss_test
    );
  
  clk_process : process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
  end process;
  

-- base value slave
-- signal val_xor : std_logic_vector(7 downto 0) := "00110011";
-- signal val_and : std_logic_vector(7 downto 0) := "10100000";
-- signal val_or  : std_logic_vector(7 downto 0) := "11001100";

  stim_proc: process
    begin
      wait for 100 ns;
      reset <= '1';
      
      wait for clk_period*5;
      -- test default value slave
      v1_mtr <= "10101010"; --val test1
      v2_mtr <= "01010101"; --val test1
      en_mtr <= '1', '0' after clk_period*2;
      wait until busy_mtr = '0';
      assert( v_xor = "00110011") report "xor default incorrect";
      assert( v_and = "10100000") report "and default incorrect";
      assert( v_or = "11001100") report "or default incorrect";

      -- test 1
      v1_mtr <= "11001101"; --val test2
      v2_mtr <= "01010110"; --val test2
      en_mtr <= '1', '0' after clk_period*2;
      wait until busy_mtr = '0';
      assert( v_xor = "11111111") report "xor test1 incorrect";
      assert( v_and = "00000000") report "and test1 incorrect";
      assert( v_or = "11111111") report "or test1 incorrect";

      --test 2
      v1_mtr <= "10110000"; --val test3
      v2_mtr <= "01001100"; --val test3
      en_mtr <= '1', '0' after clk_period*2;
      wait until busy_mtr = '0';
      assert( v_xor = "10011011") report "xor test2 incorrect";
      assert( v_and = "01000100") report "and test2 incorrect";
      assert( v_or = "11011111") report "or test2 incorrect";
      
      --test 3
      v1_mtr <= "11001010"; --val test4
      v2_mtr <= "01011001"; --val test4
      en_mtr <= '1', '0' after clk_period*2;
      wait until busy_mtr = '0';
      assert( v_xor = "11111100") report "xor test3 incorrect";
      assert( v_and = "00000000") report "and test3 incorrect";
      assert( v_or = "11111100") report "or test3 incorrect";
      
      --test 4
      v1_mtr <= "11010100"; --val test5
      v2_mtr <= "00111101"; --val test5
      en_mtr <= '1', '0' after clk_period*2;
      wait until busy_mtr = '0';
      assert( v_xor = "10010011") report "xor test4 incorrect";
      assert( v_and = "01001000") report "and test4 incorrect";
      assert( v_or = "11011011") report "or test4 incorrect";
      
      --test 5
      v1_mtr <= "00000000"; --untested
      v2_mtr <= "00000000"; --untested
      en_mtr <= '1', '0' after clk_period*2;
      wait until busy_mtr = '0';
      assert( v_xor = "11101001") report "xor test5 incorrect";
      assert( v_and = "00010100") report "and test5 incorrect";
      assert( v_or = "11111101") report "or test5 incorrect";

      wait;
    end process;

end behavior;