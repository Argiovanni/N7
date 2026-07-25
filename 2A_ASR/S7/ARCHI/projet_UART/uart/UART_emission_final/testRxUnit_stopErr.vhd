LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY testRxUnit_stopErr IS
END testRxUnit_stopErr;

ARCHITECTURE behavior OF testRxUnit_stopErr IS 

    component RxUnit IS
        PORT (
        clk, reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        read : IN STD_LOGIC;
        rxd : IN STD_LOGIC;
        data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Ferr, OErr, DRdy : OUT STD_LOGIC);
    END component;

    COMPONENT clkUnit
        PORT(
            clk : IN  std_logic;
            reset : IN  std_logic;
            enableTX : OUT  std_logic;
            enableRX : OUT  std_logic
        );
    END COMPONENT;	

    COMPONENT TxUnit
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        enable : IN  std_logic;
        ld : IN  std_logic;
        txd : OUT  std_logic;
        regE : OUT  std_logic;
        bufE : OUT  std_logic;
        data : IN  std_logic_vector(7 downto 0)
    );
    END COMPONENT;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal enableTx : std_logic := '0';
    signal enableRx : std_logic := '0';

    constant clk_period : time := 10 ns;

    -- signaux à vérifier
    signal Ferr, OErr, DRdy : STD_LOGIC;
    signal data : std_logic_vector(7 downto 0);

    signal read : std_logic := '0';
    signal rxd,txd,val_set,ld,force : std_logic;
    signal data_in : std_logic_vector(7 downto 0);

begin
    rx_inst: RxUnit PORT MAP (
            clk => clk,
            reset => reset,
            enable => enableRX,
            read => read,
            rxd => rxd,
            data => data,
            Ferr => Ferr,
            OErr => OErr,
            DRdy => DRdy
        );

    clkUnit_inst: clkUnit PORT MAP (
                clk => clk,
                reset => reset,
                enableTX => enableTX,
                enableRX => enableRX
            );
    
    clk_process : process
        begin
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end process;

    txUnit_inst: TxUnit port map (
            clk => clk,
            enable => enableTx,
            reset => reset,
            ld => ld,
            txd => txd,
            regE => open,
            bufE => open,
            data => data_in
          );

    rxd <= val_set when force = '1' else txd;

    stim_proc: process
        begin		
            wait for 100 ns;	
            reset <= '1';
            wait for 100 ns;

            data_in <= "10100101"; 
            ld <= '1';
            wait for (clk_period); 
            ld <= '0';
            wait for (clk_period * 5); 
            wait for (clk_period * (16 * 10));
            val_set <= '0';
            force <= '1';
            wait for (clk_period * 12);
            force <= '0';

            assert DRdy = '0' report "DRdy error" severity error;
            read <= '1';
            wait for (clk_period);
            assert Ferr = '1' report "Ferr error" severity error;
            assert OErr = '0' report "OErr erro" severity error;
            read <= '0';
        
            wait for 100 ns;
            wait;
    end process;
end;
    
