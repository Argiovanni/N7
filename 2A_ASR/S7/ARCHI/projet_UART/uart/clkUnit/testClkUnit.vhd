--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:03:15 10/31/2018
-- Design Name:   
-- Module Name:   TestClkUnit.vhd
-- Project Name:  uart
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clkUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY testClkUnit IS
END testClkUnit;
 
ARCHITECTURE behavior OF testClkUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clkUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enableTX : OUT  std_logic;
         enableRX : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal enableTX : std_logic;
   signal enableRX : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: clkUnit PORT MAP (
          clk => clk,
          reset => reset,
          enableTX => enableTX,
          enableRX => enableRX
        );

   -- Clock process definitions
   clk_process :process
   begin
     clk <= '0';
     wait for clk_period/2;
     clk <= '1';
     wait for clk_period/2;
   end process;

  reset <= '0', '1' after 100 ns;

end behavior;
