library IEEE;
use IEEE.std_logic_1164.all;

entity echoUnit is
    port (
      clk, reset : in  std_logic;
      cs, rd, wr : out  std_logic;
      IntR       : in std_logic;         -- interruption de réception
      IntT       : in std_logic;         -- interruption d'émission
      addr       : out  std_logic_vector(1 downto 0);
      data_in    : in  std_logic_vector(7 downto 0);
      data_out   : out std_logic_vector(7 downto 0));
end echoUnit;

architecture echoUnit_arch of echoUnit is

	type t_etat is (test_emission, attente, reception, attente_emission, pret_a_emettre, emission);
	signal etat : t_etat := attente;
	signal donnee : std_logic_vector(7 downto 0):=(others => '0');
	
begin

	process (clk, reset)
	begin

          if reset='0' then

            etat <= test_emission;
            
          elsif rising_edge(clk) then

            case etat is

              -- cet état n'est destiné qu'à tester l'émission
              when test_emission =>
                cs <= '1';
                rd <= '1';
                wr <= '1';
                data_out <= (others=>'0');
                addr <= (others=>'0');
                -- donnée = caractère A (0x41) (poids faibles d'abord)
                donnee <= "10000010";
                etat <= pret_a_emettre;
                        
              when attente => 
                cs <= '1';
                rd <= '1';
                wr <= '1';
                data_out <= (others=>'0');
                addr <= (others=>'0');
                if (IntR = '0') then
                  -- IntR=0 -> une nouvelle donnée est reçue
                  -- on la lit
                  etat <= reception;
                  cs <= '0';
                  rd <= '0';
                  wr <= '1';
                end if;

              when reception => 
                donnee <= data_in;
                if (IntR = '1') then
                  -- la donnée est lue
                  addr <= "00";
                  etat <= attente_emission;
                end if;
                        
              when attente_emission =>
                cs <= '1';
                rd <= '1';
                wr <= '1';
                etat <= pret_a_emettre;

              when pret_a_emettre =>
                -- pour savoir si l'unité d'émission est prête
                -- on teste le registre de contrôle
                cs <= '0';
                rd <= '0';
                wr <= '1';
                addr <= "01";
                -- le bit 3 correspond à TxRdy = 1
                if data_in(3)='1' then
                  cs <= '1';
                  rd <= '1';
                  wr <= '1';
                  etat <= emission;
                end if;
                        
              when emission =>
                -- on écrit la donnée dans le buffer d'émission
                cs <= '0';
                rd <= '1';
                wr <= '0';
                data_out <= donnee;
                donnee <= (others=>'0');
                etat <= attente;
                      
            end case;
          end if;
        end process;
	
end echoUnit_arch;
