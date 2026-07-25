library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration: Defines the inputs and outputs of the module
entity er_1octet is
  port (
    rst   : in std_logic;                -- Reset signal (active low)
    clk   : in std_logic;                -- Clock signal
    en    : in std_logic;                -- Enable signal to start the operation
    din   : in std_logic_vector(7 downto 0); -- Data input (8 bits)
    miso  : in std_logic;                -- Master In Slave Out signal (received bit)
    sclk  : out std_logic;               -- Serial Clock (output to control data transfer)
    mosi  : out std_logic;               -- Master Out Slave In (transmitted bit)
    dout  : out std_logic_vector(7 downto 0); -- Data output (8 bits)
    busy  : out std_logic                -- Busy signal indicating the operation is ongoing
  );
end er_1octet;

-- Architecture definition: Behavioral description of the entity
architecture behavioral of er_1octet is
  -- Declare a custom state type to represent the finite states of the process
  type t_etat is (idle, reception_bit, envoie_bit);  -- States: idle, reception (receiving bits), envoie (sending bits)
  signal etat : t_etat;   -- Signal to hold the current state

begin

  -- Main process sensitive to clock and reset signals
  process(clk, rst)
    variable cpt_bit : natural := 0;                      -- Counter for bit index (0 to 7)
    variable rg_din : std_logic_vector(7 downto 0);        -- Register to hold input data (8 bits)
  begin
    
    -- Reset condition (if reset is low, initialize signals)
    if (rst = '0') then
      busy <= '0';                  -- Set busy signal low (not busy)
      cpt_bit := 0;                 -- Reset the bit counter to 0
      sclk <= '1';                  -- Set serial clock high (idle state)
      etat <= idle;                 -- Set state to idle

    -- Main process behavior on rising edge of the clock
    elsif (rising_edge(clk)) then
      case etat is

        -- IDLE State: Wait for enable signal to start operation
        when idle =>
          if (en = '1') then
            busy <= '1';                 -- Set busy signal high (operation ongoing)
            sclk <= '0';                 -- Set serial clock low (start data transfer)
            rg_din := din;              -- Load input data into the register
            cpt_bit := 7;               -- Start counting from the most significant bit (MSB)
            mosi <= rg_din(cpt_bit);    -- Set MOSI to the most significant bit of input data
            etat <= reception_bit;      -- Transition to reception_bit state
          end if;

        -- reception_bit State: Wait for a bit to be received on MISO and transfer it to register
        when reception_bit =>
            if (cpt_bit > 0) then
              sclk <= '1';               -- Set serial clock high (to sample the incoming bit)
              rg_din(cpt_bit) := miso;   -- Store received bit into the register
              etat <= envoie_bit;        -- Transition to envoie_bit state to send the next bit
            elsif (cpt_bit = 0) then
              sclk <= '1';               -- Set serial clock high (final bit reception)
              rg_din(cpt_bit) := miso;   -- Store the final received bit
              busy <= '0';               -- Set busy signal low (operation completed)
              dout <= rg_din;            -- Output the received data
              etat <= idle;              -- Transition back to idle state
            end if;

        -- envoie_bit State: Send the next bit on MOSI and update the bit counter
        when envoie_bit =>
              sclk <= '0';               -- Set serial clock low (prepare for next bit transfer)
              cpt_bit := cpt_bit - 1;    -- Decrease the bit counter to move to the next bit
              mosi <= rg_din(cpt_bit);   -- Set MOSI to the next bit to send
              etat <= reception_bit;     -- Transition to reception_bit state to receive the next bit

      end case;
    end if;
  end process;

end behavioral;
