library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_TOP is
end TB_TOP;

architecture Behavioral of TB_TOP is
signal Clk_100MHz,RESET,Sortie_DCC : std_logic := '0';
signal Interrupteur : std_logic_vector(7 downto 0) := "00000000";

begin

TOP : entity work.TOP
port map(Clk_100MHz, RESET, Interrupteur, Sortie_DCC);

Clk_100MHz <= not Clk_100MHz after 5 ns;
Reset <= '1' after 2 ns, '0' after 10 ns;

Interrupteur <= "10000000" after 50 ms, "010000000" after 100 ms, "001000000" after 150 ms,
                "00010000" after 200 ms, "000010000" after 250 ms, "000000100" after 300 ms,
                "00000010" after 350 ms, "000000001" after 400 ms;


end Behavioral;
