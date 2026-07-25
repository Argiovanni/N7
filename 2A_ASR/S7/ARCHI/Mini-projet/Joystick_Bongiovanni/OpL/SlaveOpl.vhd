library ieee;
    use ieee.std_logic_1164.all;

entity SlaveOpl is
  port(
    sclk : in  std_logic;
    mosi : in  std_logic;
    miso : out std_logic;
    ss   : in  std_logic
  );
end SlaveOpl;

--------------------------------------------------------------------------------

architecture behavioral of SlaveOpl is

  signal v1 : std_logic_vector(7 downto 0) := (others => 'U');
  signal v2 : std_logic_vector(7 downto 0) := (others => 'U');
  -- les valeurs initiales de val_xor, val_and et val_or
  -- sont les valeurs émises -- lors de la première transmission
  signal val_xor : std_logic_vector(7 downto 0) := "00110011";
  signal val_and : std_logic_vector(7 downto 0) := "10100000";
  signal val_or  : std_logic_vector(7 downto 0) := "11001100";

  signal count_mosi     : natural;  -- bit index dans l'octet à recevoir
  signal num_octet_mosi : natural;  -- index de l'octet à recevoir

  signal count_miso     : natural;  -- bit index dans l'octet à envoyer
  signal num_octet_miso : natural;  -- index de l'octet à envoyer

begin

  -- process de capture des 3 octets sur front montant de sclk
  capture : process(ss, sclk)
  begin
    if ( ss = '1' ) then  -- ss est un reset asynchrone
      count_mosi     <= 7;
      num_octet_mosi <= 0;
    elsif ( rising_edge(sclk) ) then
      case (num_octet_mosi) is
        when 0 =>
          v1(count_mosi) <= mosi;
          --
          if ( count_mosi > 0 ) then
            count_mosi <= count_mosi - 1;
          else
            count_mosi     <= 7;
            num_octet_mosi <= num_octet_mosi + 1;
          end if;

        when 1 =>
          v2(count_mosi) <= mosi;
          --
          if ( count_mosi > 0 ) then
            count_mosi <= count_mosi - 1;
          else
            count_mosi     <= 7;
            num_octet_mosi <= num_octet_mosi + 1;
          end if;

        when others =>
          if ( count_mosi > 0 ) then
            count_mosi <= count_mosi - 1;
          else
            count_mosi     <= 7;
            num_octet_mosi <= 0;
            --
            val_xor <= v1 xor v2;
            val_and  <= v1 and  v2;
            val_or <= v1 or v2;
          end if;
      end case;
    end if;
  end process;


  -- process de "présentation" des 3 octets : val_xor, val_and et val_or
  envoi : process(ss, sclk)
  begin
    if ( ss = '1' ) then  -- ss est un reset asynchrone
      count_miso     <= 7;
      num_octet_miso <= 0;
    elsif ( falling_edge(sclk) ) then
      case (num_octet_miso) is
        when 0 =>
          miso <= val_xor(count_miso);
          --
          if ( count_miso > 0 ) then
            count_miso <= count_miso - 1;
          else
            count_miso     <= 7;
            num_octet_miso <= num_octet_miso + 1;
          end if;

        when 1 =>
          miso <= val_and(count_miso);
          --
          if ( count_miso > 0 ) then
            count_miso <= count_miso - 1;
          else
            count_miso     <= 7;
            num_octet_miso <= num_octet_miso + 1;
          end if;

        when others =>
          miso <= val_or(count_miso);
          --
          if ( count_miso > 0 ) then
            count_miso <= count_miso - 1;
          else
            count_miso     <= 7;
            num_octet_miso <= 0;
          end if;
      end case;
    end if;
  end process;

end behavioral;
