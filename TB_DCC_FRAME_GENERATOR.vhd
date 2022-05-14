library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_FRAME_GENERATOR is
end TB_FRAME_GENERATOR;

architecture Behavioral of TB_FRAME_GENERATOR is
signal Interrupteur : STD_LOGIC_VECTOR(7 downto 0) := x"00";
signal Trame_DCC : STD_LOGIC_VECTOR(50 downto 0);

begin
Generateur_Trame : entity work.DCC_FRAME_GENERATOR
port map(Interrupteur=>Interrupteur,Trame_DCC=>Trame_DCC);

Interrupteur <= "00000001" after 10 ms, 
                "00000010" after 20 ms,
                "00000100" after 30 ms,
                "00001000" after 40 ms,
                "00010000" after 50 ms,
                "00100000" after 60 ms, 
                "01000000" after 70 ms,
                "10000000" after 80 ms,
                "00000000" after 90 ms;
                
end Behavioral;